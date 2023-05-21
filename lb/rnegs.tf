locals {
  rnegs = {
    for b, v in var.backends : k => [
      for rneg in coalesce(v.rnegs, []) : {
        backend      = b
        type         = lookup(rneg, "psc_target", null) != null ? "psc" : "serverless"
        key          = "${b}-${i}"
        psc_target   = lookup(rneg, "psc_target", null)
        network_link = lookup(rneg, "psc_target", null) != null ? "projects/${local.network_project_id}/global/networks/${coalesce(rneg.network_name, var.network_name)}" : null
        subnet_id    = lookup(rneg, "psc_target", null) != null ? "${local.subnet_prefix}/${rneg.region}/subnetworks/${rneg.subnet_name}" : null
        region       = coalesce(rneg.region, v.region, local.region)
        name         = coalesce(rneg.cloud_run_name, "${b}-${i}")
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