locals {
  router_peers = [for k, v in local.router_interfaces : merge(v, {
    advertise_mode            = length(v.advertised_ip_ranges) > 0 ? "CUSTOM" : "DEFAULT"
    enable_bfd                = coalesce(v.enable_bfd, false)
    bfd_min_transmit_interval = coalesce(v.bfd_min_transmit_interval, 1000)
    bfd_min_receive_interval  = coalesce(v.bfd_min_receive_interval, 1000)
    bfd_multiplier            = coalesce(v.bfd_multiplier, 5)
    enable                    = coalesce(v.enable, true)
  })]
}

resource "google_compute_router_peer" "default" {
  for_each                  = { for i, v in local.router_peers : "${v.key}" => v }
  project                   = each.value.project_id
  name                      = each.value.peer_name
  region                    = each.value.region
  router                    = each.value.router
  interface                 = each.value.interface_name
  peer_ip_address           = each.value.peer_ip_address
  peer_asn                  = each.value.peer_asn
  advertised_route_priority = each.value.advertised_priority
  advertised_groups         = each.value.advertised_groups
  advertise_mode            = each.value.advertise_mode
  dynamic "advertised_ip_ranges" {
    for_each = each.value.advertised_ip_ranges
    content {
      range = advertised_ip_ranges.value
    }
  }
  dynamic "bfd" {
    for_each = each.value.enable_bfd ? [true] : []
    content {
      min_receive_interval        = each.value.bfd_min_receive_interval
      min_transmit_interval       = each.value.bfd_min_transit_interval
      multiplier                  = each.value.bfd_multiplier
      session_initialization_mode = "ACTIVE"
    }
  }
  enable = each.value.enable
}
