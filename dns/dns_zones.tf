locals {
  dns_zones = { for k, v in var.dns_zones : k => merge(v,
    {
      project_id          = coalesce(v.project_id, var.project_id)
      name                = coalesce(v.name, k)
      description         = coalesce(v.description, "Managed by Terraform")
      dns_name            = endswith(v.dns_name, ".") ? v.dns_name : "${v.dns_name}."
      peer_project_id     = coalesce(v.peer_project_id, var.project_id)
      visible_networks    = coalesce(v.visible_networks, [])
      target_name_servers = coalesce(v.target_name_servers, [])
      logging             = coalesce(v.logging, false)
      visibility          = lower(coalesce(v.visibility, "public"))
      records             = coalesce(v.records, [])
    }
  ) }
  dns_zones_with_visibility = { for k, v in local.dns_zones : k => merge(v,
    {
      visibility = length(v.visible_networks) > 0 ? "private" : v.visibility
    }
  ) }
}

# DNS Zones
resource "google_dns_managed_zone" "default" {
  for_each    = local.dns_zones_with_visibility
  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  dns_name    = each.value.dns_name
  visibility  = each.value.visibility
  dynamic "private_visibility_config" {
    for_each = each.value.visibility == "private" && length(each.value.visible_networks) > 0 ? [true] : []
    content {
      dynamic "networks" {
        for_each = each.value.visible_networks
        content {
          network_url = "projects/${each.value.project_id}/global/networks/${networks.value}"
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = each.value.visibility == "private" && length(each.value.target_name_servers) > 0 ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.target_name_servers
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = coalesce(target_name_servers.value.forwarding_path, "default")
        }
      }
    }
  }
  dynamic "peering_config" {
    for_each = each.value.peer_network_name != null ? [true] : []
    content {
      target_network {
        network_url = "projects/${each.value.peer_project_id}/global/networks/${each.value.peer_network_name}"
      }
    }
  }
  dynamic "cloud_logging_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable_logging = true
    }
  }
}
