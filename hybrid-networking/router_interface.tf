locals {
  router_interfaces = concat(local.interconnect_attachments, local.vpn_tunnels)
}

resource "google_compute_router_interface" "default" {
  for_each                = { for i, v in local.router_interfaces : "${v.key}" => v }
  project                 = each.value.project_id
  name                    = each.value.interface_name
  region                  = each.value.region
  router                  = each.value.router
  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.is_vpn ? try(google_compute_vpn_tunnel.default[each.value.key].name, null) : null
  interconnect_attachment = each.value.is_interconnect ? each.value.attachment_name : null
  depends_on              = [google_compute_interconnect_attachment.default, google_compute_vpn_tunnel.default]
}

