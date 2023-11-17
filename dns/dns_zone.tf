locals {
  dns_zone_0 = merge(var.dns_zone,
    {
      project_id          = coalesce(var.dns_zone.project_id, var.project_id)
      #name                = coalesce(var.dns_zone.name, "dns-zone")
      description         = coalesce(var.dns_zone.description, "Managed by Terraform")
      dns_name            = endswith(var.dns_zone.dns_name, ".") ? var.dns_zone.dns_name : "${var.dns_zone.dns_name}."
      peer_project_id     = coalesce(var.dns_zone.peer_project_id, var.project_id)
      visible_networks    = coalesce(var.dns_zone.visible_networks, [])
      target_name_servers = coalesce(var.dns_zone.target_name_servers, [])
      logging             = coalesce(var.dns_zone.logging, false)
      visibility          = lower(coalesce(var.dns_zone.visibility, "public"))
      records             = coalesce(var.dns_zone.records, [])
      force_destroy       = coalesce(var.dns_zone.force_destroy, false)
      create              = coalesce(var.dns_zone.create, true)
    }
  )
  dns_zone_1 = merge(local.dns_zone_0,
    {
          name       = lower(coalesce(local.dns_zone_0.name, trimsuffix(replace(local.dns_zone_0.dns_name, ".", "-"), "-")))
      visibility = length(local.dns_zone_0.visible_networks) > 0 ? "private" : local.dns_zone_0.visibility
    }
  )
  dns_zone = merge(local.dns_zone_1,
    {
      is_private = local.dns_zone_1.visibility == "private" ? true : false
      is_public  = local.dns_zone_1.visibility == "public" ? true : false
      key        = "${local.dns_zone_1.project_id}::${local.dns_zone_1.name}"
    }
  )
}

# DNS Zone
resource "google_dns_managed_zone" "this" {
  for_each      = { for i, v in [local.dns_zone ] : 0 => v if v.create }
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
