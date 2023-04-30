locals {
  dns_policies = { for k, v in var.dns_policies : k => merge(v,
    {
      project_id                = coalesce(v.project_id, var.project_id)
      name                      = coalesce(v.name, k)
      enable_inbound_forwarding = coalesce(v.enable_inbound_forwarding, false)
      target_name_servers       = coalesce(v.target_name_servers, [])
      networks                  = coalesce(v.networks, [])
    }
  ) }
}

# DNS Server Policies
resource "google_dns_policy" "default" {
  for_each                  = local.dns_policies
  project                   = each.value.project_id
  name                      = each.value.name
  description               = each.value.description
  enable_logging            = each.value.logging
  enable_inbound_forwarding = each.value.enable_inbound_forwarding
  dynamic "alternative_name_server_config" {
    for_each = length(each.value.target_name_servers) > 0 ? [true] : []
    content {
      dynamic "target_name_servers" {
        for_each = each.value.target_name_servers
        content {
          ipv4_address = target_name_server.value.ipv4_address
        }
      }
    }
  }
  dynamic "networks" {
    for_each = each.value.networks
    content {
      network_url = "projects/${each.value.project_id}/global/networks/${networks.value}"
    }
  }
}
