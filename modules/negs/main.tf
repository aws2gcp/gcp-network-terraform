locals {
  name        = coalesce(var.name, "tf-neg")
  description = try(lower(var.description), null)
  is_sneg     = var.params.cloud_function_name != null || var.params.cloud_run_name != null || var.params.app_engine_service != null ? true : false
  is_ineg     = local.is_sneg ? false : true
  is_regional = local.is_sneg ? true : false
  is_global   = local.is_ineg ? true : false
  create_neg  = var.create && local.is_ineg || local.is_sneg
  neg_type    = local.is_ineg ? "INEG" : local.is_sneg ? "SERVERLESS" : null
  ineg_type   = var.params.ip_address != null ? "INTERNET_IP_PORT" : "INTERNET_FQDN_PORT"
  ineg_fqdn   = local.ineg_type == "INTERNET_FQDN_PORT" ? coalesce(var.params.fqdn, "localhost.localdomain") : null
}

# Internet Network Endpoint Groups
resource "google_compute_global_network_endpoint_group" "default" {
  count                 = var.create && local.is_global ? 1 : 0
  name                  = local.name
  description           = local.description
  network_endpoint_type = local.ineg_type
  default_port          = var.params.port
  project               = var.project_id
}

# Internet Network Endpoints
resource "google_compute_global_network_endpoint" "default" {
  count                         = var.create && local.is_global ? 1 : 0
  global_network_endpoint_group = google_compute_global_network_endpoint_group.default[0].name
  fqdn                          = local.ineg_fqdn
  ip_address                    = var.params.ip_address
  port                          = var.params.port
  project                       = var.project_id
}

# Serverless Network Endpoint Groups
resource "google_compute_region_network_endpoint_group" "default" {
  count                 = var.create && local.is_regional ? 1 : 0
  name                  = local.name
  region                = var.region
  network_endpoint_type = local.neg_type
  dynamic "cloud_function" {
    for_each = var.params.cloud_function_name != null ? [true] : []
    content {
      function = var.params.cloud_function_name
    }
  }
  dynamic "cloud_run" {
    for_each = var.params.cloud_run_name != null ? [true] : []
    content {
      service = var.params.cloud_run_name
    }
  }
  dynamic "app_engine" {
    for_each = var.params.app_engine_service != null ? [true] : []
    content {
      service = var.params.app_engine_service
      version = var.params.app_engine_version_id
    }
  }
  project = var.project_id
}
