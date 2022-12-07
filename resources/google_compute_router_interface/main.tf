resource "google_compute_router_interface" "default" {
  count                   = length(var.interfaces)
  name                    = coalesce(var.interfaces[count.index].interface_name, "${local.name_prefix}-${count.index}")
  region                  = var.region
  router                  = var.cloud_router_name
  ip_range                = var.interfaces[count.index].cloud_router_ip
  vpn_tunnel              = local.type == "vpn" ? coalesce(var.interfaces[count.index].vpn_name, "${local.name_prefix}-${count.index}") : null
  interconnect_attachment = local.type == "interconnect" ? coalesce(var.interfaces[count.index].attachment_name, var.interfaces[count.index].interface_name) : null
  project                 = var.project_id
}

locals {
  type        = lower(var.type)
  name_prefix = local.type == "vpn" ? "${var.cloud_router_name}-${var.peer_vpn_gateway_name}" : var.cloud_router_name
}
