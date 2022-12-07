resource "google_dns_managed_zone" "default" {
  count       = var.name == null ? 0 : 1
  project     = var.project_id
  name        = var.name
  description = var.description
  dns_name    = var.dns_name
  visibility  = local.visibility
  dynamic "private_visibility_config" {
    for_each = local.visibility == "private" ? [true] : []
    content {
      dynamic "networks" {
        for_each = var.visible_networks
        content {
          network_url = "${local.network_prefix}/${networks.value}"
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = var.target_name_servers != null ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = var.target_name_servers
        content {
          ipv4_address    = target_name_servers.value
          forwarding_path = local.visibility == "private" ? "private" : "default"
        }
      }
    }
  }
  dynamic "peering_config" {
    for_each = var.peer_network_name != null ? [true] : []
    content {
      target_network {
        network_url = "${local.peer_network_prefix}/${var.peer_network_name}"
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = var.logging != null && var.logging == true ? [true] : []
    content {
      enable_logging = true
    }
  }
}

locals {
  visibility          = length(var.visible_networks) > 0 || var.peer_network_name != null ? "private" : lower(coalesce(var.visibility, "public"))
  network_prefix      = "projects/${var.project_id}/global/networks"
  peer_network_prefix = "projects/${local.peer_project_id}/global/networks"
  peer_project_id     = coalesce(var.peer_project_id, var.project_id)
}
