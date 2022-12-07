resource "google_compute_forwarding_rule" "default" {
  count       = var.name == null ? 0 : 1
  name        = var.name
  ip_address  = var.ip_address
  ip_protocol = local.ip_protocol
  target      = local.target
  #backend_service       = var.backend_service_name != null && var.tproxy_id == null ? local.backend_service_id : null
  backend_service       = var.backend_service_name != null && local.target == null ? local.backend_service_id : null
  load_balancing_scheme = var.lb_scheme
  port_range            = var.port_range
  ports                 = length(var.ports) > 0 ? var.ports : null
  all_ports             = length(var.ports) > 0 || var.port_range != null || var.target_id != null ? false : true
  network               = var.target_id != null ? var.vpc_network_name : null
  subnetwork            = var.lb_scheme == "INTERNAL" || var.lb_scheme == "INTERNAL_MANAGED" ? local.subnet_id : null
  network_tier          = coalesce(var.network_tier, var.lb_scheme == "EXTERNAL" ? "PREMIUM" : null)
  region                = var.region
  allow_global_access   = var.allow_global_access
  project               = var.project_id
}

locals {
  network_project_id = coalesce(var.network_project_id, var.project_id)
  subnet_id          = "projects/${local.network_project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  backend_service_id = var.backend_service_name != null ? "projects/${local.network_project_id}/regions/${var.region}/backendServices/${var.backend_service_name}" : null
  ip_protocol        = coalesce(var.protocol, var.lb_scheme == "INTERNAL" ? "TCP" : null)
  target             = var.tproxy_id != null || var.target_id != null ? coalesce(var.tproxy_id, var.target_id) : null
}
