locals {
  vpn_tunnels_0 = flatten([for i, v in var.vpns : [for t, tunnel in v.tunnels : {
    create                          = coalesce(tunnel.create, true)
    is_vpn                          = true
    is_interconnect                 = false
    project_id                      = coalesce(v.project_id, var.project_id)
    region                          = coalesce(v.region, var.region)
    router                          = coalesce(v.cloud_router, try(local.cloud_routers[v.cloud_router].name, null), "error")
    cloud_vpn_gateway               = v.cloud_vpn_gateway
    peer_gcp_vpn_gateway_project_id = coalesce(v.peer_gcp_vpn_gateway_project_id, v.project_id, var.project_id)
    peer_gcp_vpn_gateway            = v.peer_gcp_vpn_gateway
    peer_external_gateway           = try(coalesce(v.peer_vpn_gateway, try(local.peer_vpn_gateways[v.peer_vpn_gateway].name, null)), null)
    description                     = try(coalesce(tunnel.description, v.description), null)
    ip_range                        = tunnel.cloud_router_ip
    interface_name                  = coalesce(tunnel.interface_name, "vpn-${i}-${t}")
    peer_name                       = coalesce(tunnel.bgp_name, "vpn-${i}-${t}")
    ike_version                     = coalesce(tunnel.ike_version, var.defaults.vpn_ike_version, 2)
    ike_psk                         = tunnel.ike_psk
    vpn_gateway_interface           = coalesce(tunnel.interface_index, t % 2 == 0 ? 0 : 1)
    peer_external_gateway_interface = coalesce(tunnel.peer_interface_index, t)
    advertised_ip_ranges            = coalesce(tunnel.advertised_ip_ranges, v.advertised_ip_ranges, [])
    advertised_groups               = coalesce(tunnel.advertised_groups, v.advertised_groups, [])
    advertised_priority             = coalesce(tunnel.advertised_priority, v.advertised_priority, 100)
    peer_ip_address                 = tunnel.bgp_peer_ip
    peer_asn                        = try(coalesce(tunnel.peer_bgp_asn, v.peer_bgp_asn), null)
    enable_bfd                      = try(coalesce(tunnel.enable_bfd, v.enable_bfd), null)
    bfd_min_transmit_interval       = 1000
    bfd_min_receive_interval        = 1000
    bfd_multiplier                  = v.bfd_multiplier
    vpn_name                        = v.name
    tunnel_name                     = tunnel.name
    vpn_index                       = i
    tunnel_index                    = t
  }]])
  vpn_tunnels_1 = [for i, v in local.vpn_tunnels_0 : merge(v, {
    name        = coalesce(v.tunnel_name, v.vpn_name != null ? "${v.vpn_name}-${v.tunnel_index}" : null, "${v.vpn_index}-${v.tunnel_index}")
    peer_is_gcp = v.peer_gcp_vpn_gateway != null ? true : false
  })]
  vpn_tunnels_2 = [for i, v in local.vpn_tunnels_1 : merge(v, {
    key = "${v.project_id}-${v.region}-${v.name}"
  })]
}

# If IKE PSK not provided, generate some random 20-character ones
resource "random_string" "ike_psks" {
  for_each = { for i, v in local.vpn_tunnels_2 : v.key => v if v.ike_psk == null }
  length   = 20
  special  = false
}

locals {
  gcp_gateway_prefix = "https://www.googleapis.com/compute/v1/projects"
  vpn_tunnels = [for i, v in local.vpn_tunnels_2 : merge(v, {
    cloud_vpn_gateway_name = coalesce(
      v.cloud_vpn_gateway,
      try(local.cloud_vpn_gateways[v.cloud_vpn_gateway].name, null),
      "error"
    )
    peer_gcp_gateway_link = v.peer_is_gcp ? "${local.gcp_gateway_prefix}/${v.peer_gcp_vpn_gateway_project_id}/regions/${v.region}/vpnGateways/${v.peer_gcp_vpn_gateway_name}" : null
    ike_psk = coalesce(
      v.ike_psk,
      try(resource.random_string.ike_psks[v.key].result, null),
      var.defaults.vpn_ike_psk,
    )
    peer_external_gateway_interface = v.peer_is_gcp ? null : v.peer_external_gateway_interface
  })]
}

resource "google_compute_vpn_tunnel" "default" {
  for_each                        = { for i, v in local.vpn_tunnels : v.key => v if v.create }
  project                         = each.value.project_id
  name                            = each.value.name
  description                     = each.value.description
  region                          = each.value.region
  router                          = each.value.router
  vpn_gateway                     = each.value.cloud_vpn_gateway_name
  peer_external_gateway           = each.value.peer_external_gateway
  peer_gcp_gateway                = each.value.peer_gcp_gateway_link
  ike_version                     = each.value.ike_version
  shared_secret                   = each.value.ike_psk
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  depends_on                      = [google_compute_ha_vpn_gateway.default, google_compute_external_vpn_gateway.default]
}
