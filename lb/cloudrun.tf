locals {
  new_cloud_runs = [for rneg in local.new_rnegs : rneg if rneg.type == "cloud_run"]
  cloud_run_allowed_members = flatten([for new_cloud_run in local.new_cloud_runs : [
    for i, member in new_cloud_run.allow_unauthenticated ? ["allUsers"] : new_cloud_run.allowed_members : {
      key           = "${new_cloud_run.key}-${i}"
      cloud_run_key = new_cloud_run.key
      member        = member
      role          = "roles/run.invoker"
    }
  ]])
}

# Create Cloud Run Service
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

# Enable Cloud Run invoker role for appropriate members
resource "google_cloud_run_service_iam_member" "default" {
  for_each = { for allowed_member in local.cloud_run_allowed_members : "${allowed_member.key}" => allowed_member }
  project  = var.project_id
  service  = google_cloud_run_service.default[each.value.cloud_run_key].name
  location = google_cloud_run_service.default[each.value.cloud_run_key].location
  role     = each.value.role
  member   = each.value.member
}
