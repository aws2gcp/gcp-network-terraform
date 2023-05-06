output "cloud_vpn_gateways" {
  value = { for k, v in local.cloud_vpn_gateways : k => {
    name         = v.name
    region       = v.region
    ip_addresses = google_compute_ha_vpn_gateway.default[k].vpn_interfaces.*.ip_address
    }
  }
}

output "vpn_tunnels" {
  value = { for k, v in local.vpn_tunnels_with_psks : k => {
    name            = v.name
    peer_ip_address = v.peer_ip_address
    vpn_gateway_ip  = google_compute_ha_vpn_gateway.default[v.vpn_gateway].vpn_interfaces[v.vpn_gateway_interface].ip_address
    shared_secret   = v.shared_secret
    }
  }
}
