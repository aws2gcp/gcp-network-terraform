locals {
  rnegs = {
    for k, v in var.backends : k => [
      for i, rneg in coalesce(v.rnegs, []) : {
        backend      = k
        type         = lookup(rneg, "psc_target", null) != null ? "psc" : "serverless"
        key          = "${k}-${i}"
        psc_target   = lookup(rneg, "psc_target", null)
        network_link = lookup(rneg, "psc_target", null) != null ? "projects/${local.network_project_id}/global/networks/${coalesce(rneg.network_name, var.network_name)}" : null
        subnet_id    = lookup(rneg, "psc_target", null) != null ? "${local.subnet_prefix}/${rneg.region}/subnetworks/${rneg.subnet_name}" : null
        region       = coalesce(rneg.region, v.region, local.region)
        name         = coalesce(rneg.cloud_run_name, "${k}-${i}")
        image = try(coalesce(
          lookup(rneg, "docker_image", null) != null ? (length(split("/", rneg.docker_image)) > 1 ? "docker.io/${rneg.docker_image}" : "docker.io/library/${rneg.docker_image}") : null,
          lookup(rneg, "container_image", null) != null ? (length(split("/", rneg.container_image)) > 1 ? rneg.container_image : "gcr.io/${var.project_id}/${rneg.container_image}") : null,
        ), null)
        port                  = coalesce(rneg.container_port, v.port, 80)
        allow_unauthenticated = coalesce(rneg.allow_unauthenticated, false)
        allowed_members       = coalesce(rneg.allowed_members, [])
      }
    ] if length(coalesce(v.rnegs, [])) > 0 && local.is_http
  }
  new_rnegs = flatten([
    for k, rnegs in local.rnegs : [
      for i, rneg in coalesce(rnegs, []) : merge(rneg, {
        key  = "${rneg.backend}-${i}"
        type = rneg.image != null ? "cloud_run" : rneg.type
      })
    ]
  ])
  new_cloud_runs = [for rneg in local.new_rnegs : rneg if rneg.type == "cloud_run"]
}

resource "google_cloud_run_service" "default" {
  for_each = { for k, v in local.new_cloud_runs : "${v.key}" => v }
  project  = var.project_id
  name     = each.value.name
  location = each.value.region
  template {
    spec {
      containers {
        image = each.value.image
        ports {
          name           = "http1"
          container_port = each.value.port
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

locals {
  cloud_run_allowed_members = flatten([for new_cloud_run in local.new_cloud_runs : [
    for i, member in new_cloud_run.allow_unauthenticated ? ["allUsers"] : new_cloud_run.allowed_members : {
      key           = "${new_cloud_run.key}-${i}"
      cloud_run_key = new_cloud_run.key
      member        = member
      role          = "roles/run.invoker"
    }
  ]])
}

# Enable Cloud Run invoker role for appropriate members
resource "google_cloud_run_service_iam_member" "default" {
  for_each = { for allowed_member in local.cloud_run_allowed_members : "${allowed_member.key}" => allowed_member }
  project  = var.project_id
  service  = google_cloud_run_service.default[each.value.cloud_run_key].name
  location = google_cloud_run_service.default[each.value.cloud_run_key].location
  role     = each.value.role
  member   = each.value.member
}

# Regional Network Endpoint Group (used by PSC and Serverless Backends)
resource "google_compute_region_network_endpoint_group" "default" {
  for_each              = { for rneg in local.new_rnegs : "${rneg.key}" => rneg }
  project               = var.project_id
  name                  = each.value.name
  network_endpoint_type = each.value.type == "psc" ? "PRIVATE_SERVICE_CONNECT" : "SERVERLESS"
  region                = each.value.region
  psc_target_service    = each.value.type == "psc" ? each.value.psc_target : null
  network               = each.value.network_link
  subnetwork            = each.value.subnet_id
  dynamic "cloud_run" {
    for_each = each.value.type == "cloud_run" ? [true] : []
    content {
      service = google_cloud_run_service.default[each.key].name
    }
  }
}