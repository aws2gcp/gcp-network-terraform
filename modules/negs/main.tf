locals {
  create_neg  = coalesce(var.create, true) && local.is_ineg || local.is_sneg
  name        = coalesce(var.name, "tf-neg")
  description = try(lower(var.description), null)
  is_sneg     = var.params.cloud_function_name != null || var.params.cloud_run_name != null || var.params.app_engine_service != null ? true : false
  is_ineg     = var.params.ip_address != null || var.params.fqdn != null && !local.is_sneg ? true : false
  is_regional = local.is_sneg ? true : false
  is_global   = local.is_ineg ? true : false
  neg_type    = local.is_ineg ? local.ineg_type : local.is_sneg ? "SERVERLESS" : null
  ineg_type   = var.params.ip_address != null ? "INTERNET_IP_PORT" : "INTERNET_FQDN_PORT"
  ineg_fqdn   = local.ineg_type == "INTERNET_FQDN_PORT" ? coalesce(var.params.fqdn, "localhost.localdomain") : null
  protocol    = upper(coalesce(var.params.protocol, "https"))
  port        = coalesce(var.params.port, local.protocol == "HTTPS" ? 443 : 80)
}

# Internet Network Endpoint Groups
resource "google_compute_global_network_endpoint_group" "default" {
  count                 = local.create_neg && local.is_global ? 1 : 0
  name                  = local.name
  description           = local.description
  network_endpoint_type = local.neg_type
  default_port          = local.port
  project               = var.project_id
}

# Internet Network Endpoints
resource "google_compute_global_network_endpoint" "default" {
  count                         = local.create_neg && local.is_global ? 1 : 0
  global_network_endpoint_group = one(google_compute_global_network_endpoint_group.default.*).name
  fqdn                          = local.ineg_fqdn
  ip_address                    = var.params.ip_address
  port                          = local.port
  project                       = var.project_id
}

# Serverless Network Endpoint Groups
resource "google_compute_region_network_endpoint_group" "default" {
  count                 = local.create_neg && local.is_regional ? 1 : 0
  name                  = local.name
  network_endpoint_type = local.neg_type
  region                = var.params.region
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