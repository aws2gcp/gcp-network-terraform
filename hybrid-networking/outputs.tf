output "cloud_routers" {
  value = [for i, v in local.cloud_routers : {
    name         = v.name
    region       = v.region
    network_name = v.network_name
    bgp_asn      = v.bgp_asn
  } if v.create]
}

output "cloud_vpn_gateways" {
  value = [for i, v in local.cloud_vpn_gateways : {
    name         = v.name
    region       = v.region
    ip_addresses = try(google_compute_ha_vpn_gateway.default[v.key].vpn_interfaces.*.ip_address, [])
  } if v.create]
}

output "peer_vpn_gateways" {
  value = [for i, v in local.peer_vpn_gateways : {
    name            = v.name
    redundancy_type = v.redundancy_type
    ip_addresses = [
      for interface in try(google_compute_external_vpn_gateway.default[v.key].interface, []) : interface.ip_address
    ]
  } if v.create]
}

output "vpn_tunnels" {
  value = [for i, v in local.vpn_tunnels : {
    name                 = v.name
    peer_ip_address      = v.peer_ip_address
    peer_gateway_ip      = try(google_compute_vpn_tunnel.default[v.key].peer_ip, null)
    cloud_vpn_gateway_ip = try(google_compute_ha_vpn_gateway.default[v.cloud_vpn_gateway].vpn_interfaces[v.vpn_gateway_interface].ip_address, [])
    ike_version          = v.ike_version
    ike_psk              = v.ike_psk
    detailed_status      = try(google_compute_vpn_tunnel.default[v.key].detailed_status, "Unknown")
  } if v.create]
}
