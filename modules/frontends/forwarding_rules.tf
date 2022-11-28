# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  count                 = var.create && local.is_global ? 1 : 0
  name                  = local.name
  ip_address            = google_compute_global_address.default[0].address
  port_range            = local.http_port_range
  target                = local.create_http ? local.http_target : (local.create_https ? local.https_target : null)
  load_balancing_scheme = local.lb_scheme
  network               = var.params.vpc_network_name
  project               = var.project_id
}

# Regional Forwarding Rule
resource "google_compute_forwarding_rule" "default" {
  count                 = var.create && local.is_regional ? 1 : 0
  name                  = local.name
  ip_address            = google_compute_address.default[0].address
  ip_protocol           = local.is_http || local.is_https ? null : local.protocol
  target                = local.create_http ? local.http_target : (local.create_https ? local.https_target : null)
  backend_service       = local.create_http || local.create_https ? null : local.backend_service_id
  load_balancing_scheme = local.lb_scheme
  port_range            = try(coalesce(local.http_port_range, local.https_port_range), null)
  ports                 = coalesce(local.ports, ["80", "443"])
  all_ports             = local.all_ports
  network               = var.params.target_id != null ? var.params.vpc_network_name : null
  subnetwork            = local.type == "INTERNAL" ? local.subnet_id : null
  network_tier          = local.network_tier
  region                = var.region
  allow_global_access   = local.is_http || local.is_https || local.type == "EXTERNAL" ? null : var.params.allow_global_access
  project               = var.project_id
}

