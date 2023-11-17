locals {
  dns_zones_0 = [for i, v in var.dns_zones : merge(v,
    {
      project_id          = coalesce(v.project_id, var.project_id)
      description         = coalesce(v.description, "Managed by Terraform")
      dns_name            = endswith(v.dns_name, ".") ? v.dns_name : "${v.dns_name}."
      peer_project_id     = coalesce(v.peer_project_id, var.project_id)
      visible_networks    = coalesce(v.visible_networks, [])
      target_name_servers = coalesce(v.target_name_servers, [])
      logging             = coalesce(v.logging, false)
      visibility          = lower(coalesce(v.visibility, "public"))
      records             = coalesce(v.records, [])
      force_destroy       = coalesce(v.force_destroy, false)
      create              = coalesce(v.create, true)
    }
  )]
  dns_zones_1 = [for i, v in local.dns_zones_0 : merge(v,
    {
      name       = lower(coalesce(v.name, trimsuffix(replace(v.dns_name, ".", "-"), "-")))
      visibility = length(v.visible_networks) > 0 ? "private" : v.visibility
    }
  )]
  dns_zones = [for i, v in local.dns_zones_1 : merge(v,
    {
      is_private = v.visibility == "private" ? true : false
      is_public  = v.visibility == "public" ? true : false
      key        = "${v.project_id}::${v.name}"
    }
  )]
}

# DNS Zones
resource "google_dns_managed_zone" "default" {
  for_each      = { for i, v in local.dns_zones : v.key => v if v.create }
  project       = each.value.project_id
  name          = each.value.name
  description   = each.value.description
  dns_name      = each.value.dns_name
  visibility    = each.value.visibility
  force_destroy = each.value.force_destroy
  dynamic "private_visibility_config" {
    for_each = each.value.is_private && length(each.value.visible_networks) > 0 ? [true] : []
    content {
      dynamic "networks" {
        for_each = each.value.visible_networks
        content {
          network_url = "${local.url_prefix}/${each.value.project_id}/global/networks/${networks.value}"
        }
      }
    }
  }
  dynamic "forwarding_config" {
    for_each = each.value.is_private && length(each.value.target_name_servers) > 0 ? [true] : []
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
