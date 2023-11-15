locals {
  dns_policies_0 = [for i, v in var.dns_policies : merge(v,
    {
      project_id                = coalesce(v.project_id, var.project_id)
      name                      = coalesce(v.name, "dns-policy-${i}")
      description               = coalesce(v.description, "Managed by Terraform")
      enable_inbound_forwarding = coalesce(v.enable_inbound_forwarding, true)
      target_name_servers       = coalesce(v.target_name_servers, [])
      networks                  = coalesce(v.networks, [])
      logging                   = coalesce(v.logging, false)
      create                    = coalesce(v.create, true)
    }
  )]
  dns_policies = [for i, v in local.dns_policies_0 : merge(v,
    {
      key = "${v.project_id}::${v.name}"
    }
  )]
}

# DNS Server Policies
resource "google_dns_policy" "default" {
  for_each                  = { for k, v in local.dns_policies : v.key => v if v.create }
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
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = coalesce(target_name_servers.value.forwarding_path, "default")
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
