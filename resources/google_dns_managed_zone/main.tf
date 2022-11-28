resource "google_dns_managed_zone" "default" {
  count       = var.name == null ? 0 : 1
  project     = var.project_id
  name        = var.name
  description = var.description
  dns_name    = var.dns_name
  visibility  = local.visibility
  dynamic "private_visibility_config" {
    for_each = local.visibility == "private" ? [1] : []
    content {
      dynamic "networks" {
        for_each = var.visible_networks
        content {
          network_url = "${local.network_url_prefix}/${networks.value}"
        }
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = var.logging == true ? [0] : []
    content {
      enable_logging = true
    }
  }
}

locals {
  visibility         = length(var.visible_networks) > 0 ? "private" : lower(coalesce(var.visibility, "public"))
  network_url_prefix = "projects/${var.project_id}/global/networks"
}
