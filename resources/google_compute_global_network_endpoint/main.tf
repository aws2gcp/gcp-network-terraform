resource "google_compute_global_network_endpoint" "default" {
  count                         = var.fqdn == null && var.ip_address == null ? 0 : 1
  global_network_endpoint_group = var.neg_name
  fqdn                          = var.fqdn
  ip_address                    = var.ip_address
  port                          = var.port
  project                       = var.project_id
}


