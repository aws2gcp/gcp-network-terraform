locals {
  vpn_tunnels = flatten([for k, v in var.vpns : [
    for i, tunnel in v.tunnels : {
      key                             = "vpn-${k}-${i}"
      type                            = "vpn"
      project_id                      = coalesce(v.project_id, var.project_id)
      region                          = coalesce(v.region, var.region)
      router                          = v.cloud_router_name
      vpn_gateway                     = v.cloud_vpn_gateway_name
      peer_external_gateway           = v.peer_vpn_gateway_name
      name                            = coalesce(tunnel.name, "${k}-${i}")
      description                     = tunnel.description
      ip_range                        = tunnel.cloud_router_ip
      ike_psk                         = tunnel.ike_psk
      interface_name                  = coalesce(tunnel.interface_name, "vpn-${k}-${i}")
      peer_name                       = coalesce(tunnel.bgp_name, "vpn-${k}-${i}")
      ike_version                     = coalesce(tunnel.ike_version, 2)
      vpn_gateway_interface           = coalesce(tunnel.interface_index, i)
      peer_external_gateway_interface = coalesce(tunnel.interface_index, i)
      advertised_ip_ranges            = coalesce(tunnel.advertised_ip_ranges, v.advertised_ip_ranges, [])
      advertised_groups               = coalesce(tunnel.advertised_groups, v.advertised_groups, [])
      advertised_priority             = coalesce(tunnel.advertised_priority, v.advertised_priority, 100)
      bgp_name                        = tunnel.bgp_name
      peer_ip_address                 = tunnel.bgp_peer_ip
      peer_asn                        = coalesce(tunnel.peer_bgp_asn, v.peer_bgp_asn, 65000)
      enable_bfd                      = coalesce(tunnel.enable_bfd, v.enable_bfd, false)
      bfd_min_transmit_interval       = 1000
      bfd_min_receive_interval        = 1000
      bfd_multiplier                  = v.bfd_multiplier
      enable                          = coalesce(tunnel.enable, true)
    }
  ]])
}

# If IKE PSK not provided, generate some random ones
resource "random_string" "ike_psks" {
  for_each = { for i, v in local.vpn_tunnels : "${v.key}" => v if v.ike_psk == null }
  length   = 20
  special  = false
}

locals {
  vpn_tunnels_with_psks = [for vpn_tunnel in local.vpn_tunnels : merge(vpn_tunnel, {
    shared_secret = coalesce(
      vpn_tunnel.ike_psk,
      try(resource.random_string.ike_psks[vpn_tunnel.key].value, null),
      "abcdefgji01234567890",
    )
  })]
}
resource "google_compute_vpn_tunnel" "default" {
  for_each                        = { for i, v in local.vpn_tunnels_with_psks : "${v.key}" => v }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  region                          = each.value.region
  router                          = each.value.router
  vpn_gateway                     = each.value.vpn_gateway
  peer_external_gateway           = each.value.peer_external_gateway
  shared_secret                   = each.value.shared_secret
  ike_version                     = each.value.ike_version
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  depends_on                      = [google_compute_external_vpn_gateway.default, google_compute_ha_vpn_gateway.default]
}
