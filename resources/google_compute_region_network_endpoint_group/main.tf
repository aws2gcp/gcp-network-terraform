resource "google_compute_region_network_endpoint_group" "default" {
  count                 = var.region == null ? 0 : 1
  project               = var.project_id
  name                  = var.name
  region                = var.region
  network_endpoint_type = var.ne_type
  dynamic "cloud_function" {
    for_each = var.cloud_function_name != null ? [0] : []
    content {
      function = var.cloud_function_name
    }
  }
  dynamic "cloud_run" {
    for_each = var.cloud_run_name != null ? [0] : []
    content {
      service = var.cloud_run_name
    }
  }
  dynamic "app_engine" {
    for_each = var.app_engine_service != null ? [0] : []
    content {
      service = var.app_engine_service
      version = var.app_enging_version_id
    }
  }
}

