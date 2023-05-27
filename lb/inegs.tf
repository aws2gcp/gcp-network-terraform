locals {
  # From backends, create a list of objects containing only Internet Network Endpoint Groups
  new_inegs = flatten([for k, v in local.backends : {
    backend_name = v.name
    fqdn         = v.ineg.fqdn
    ip_address   = v.ineg.ip_address
    port         = coalesce(v.ineg.port, local.https_port) # Let's default to HTTPS since this is going via Internet
    protocol     = upper(coalesce(v.protocol, coalesce(v.ineg.port, local.https_port) == 80 ? "http" : "https"))
  } if v.type == "ineg" && local.is_http && local.is_global && local.is_external])
}

# Internet Network Endpoint Groups
resource "google_compute_global_network_endpoint_group" "default" {
  for_each              = local.is_global ? { for i, v in local.new_inegs : "${v.backend_name}-${i}" => v } : {}
  project               = var.project_id
  name                  = "ineg-${each.key}-${each.value.port}"
  network_endpoint_type = each.value.fqdn != null ? "INTERNET_FQDN_PORT" : "INTERNET_IP_PORT"
  default_port          = local.https_port
}

# Internet Network Endpoints
resource "google_compute_global_network_endpoint" "default" {
  for_each                      = local.is_global ? { for i, v in local.new_inegs : "${v.backend_name}-${i}" => v } : {}
  project                       = var.project_id
  global_network_endpoint_group = google_compute_global_network_endpoint_group.default[each.key].id
  fqdn                          = each.value.fqdn
  ip_address                    = each.value.fqdn != null ? null : each.value.ip_address
  port                          = each.value.port
}