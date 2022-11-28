resource "google_dns_policy" "default" {
  count                     = var.name == null ? 0 : 1
  name                      = var.name
  description               = var.description
  enable_logging            = var.logging
  enable_inbound_forwarding = var.enable_inbound_forwarding
  project                   = var.project_id
  dynamic "alternative_name_server_config" {
    for_each = length(var.target_name_servers) > 0 ? [1] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.target_name_servers
        content {
          ipv4_address = target_name_server.value.ipv4_address
        }
      }
    }
  }
  dynamic "networks" {
    for_each = var.networks
    content {
      network_url = "${local.network_url_prefix}/${networks.value}"
    }
  }
}

locals {
  network_url_prefix = "projects/${var.project_id}/global/networks"
}