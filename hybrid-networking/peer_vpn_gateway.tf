locals {
  peer_vpn_gateways = { for k, v in var.peer_vpn_gateways : k => {
    create       = coalesce(v.create, true)
    project_id   = coalesce(v.project_id, var.project_id)
    name         = coalesce(v.name, k)
    description  = v.description
    ip_addresses = coalesce(v.ip_addresses, [])
    labels       = coalesce(v.labels, {})
  } }
  redundancy_types = {
    1 = "SINGLE_IP_INTERNALLY_REDUNDANT"
    2 = "TWO_IPS_REDUNDANCY"
    4 = "FOUR_IPS_REDUNDANCY"
  }
}

# Peer (External) VPN Gateway
resource "google_compute_external_vpn_gateway" "default" {
  for_each        = { for k, v in local.peer_vpn_gateways : k => v if v.create }
  project         = each.value.project_id
  name            = each.value.name
  description     = each.value.description
  labels          = each.value.labels
  redundancy_type = lookup(local.redundancy_types, length(each.value.ip_addresses), "TWO_IPS_REDUNDANCY")
  dynamic "interface" {
    for_each = each.value.ip_addresses
    content {
      id         = interface.key
      ip_address = interface.value
    }
  }
}
