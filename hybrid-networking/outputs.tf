output "cloud_routers" {
  value = { for k, v in local.cloud_routers : k => {
    name    = v.name
    region  = v.region
    bgp_asn = v.bgp_asn
    }
  }
}

output "cloud_vpn_gateways" {
  value = { for k, v in local.cloud_vpn_gateways : k => {
    name         = v.name
    region       = v.region
    ip_addresses = try(google_compute_ha_vpn_gateway.default[k].vpn_interfaces.*.ip_address, [])
    }
  }
}

output "vpn_tunnels" {
  value = { for k, v in local.vpn_tunnels : k => {
    name                 = v.name
    peer_ip_address      = v.peer_ip_address
    peer_vpn_gateway_ip  = try(local.peer_vpn_gateways[v.peer_external_gateway].ip_addresses[v.peer_external_gateway_interface], null)
    cloud_vpn_gateway_ip = try(google_compute_ha_vpn_gateway.default[v.cloud_vpn_gateway].vpn_interfaces[v.vpn_gateway_interface].ip_address, [])
    ike_version          = v.ike_version
    ike_psk              = v.ike_psk
    detailed_status      = try(google_compute_vpn_tunnel.default[v.key].detailed_status, "Unknown")
    }
  }
}
