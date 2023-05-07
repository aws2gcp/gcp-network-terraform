locals {
  router_interfaces = concat(local.interconnect_attachments, local.vpn_tunnels)
  vpn_tunnel_names  = { for i, v in local.vpn_tunnels : "${v.key}" => v.name }
}

# Cloud Router Interface
resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : "${v.key}" => v if v.enable == true }
  project                 = each.value.project_id
  name                    = each.value.interface_name
  region                  = each.value.region
  router                  = each.value.router
  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.is_vpn ? local.vpn_tunnel_names[each.value.key] : null
  interconnect_attachment = each.value.is_interconnect ? each.value.attachment_name : null
  depends_on              = [google_compute_interconnect_attachment.default, google_compute_vpn_tunnel.default]
}

