resource "google_compute_network_endpoint" "default" {
  count = var.ip_address == null ? 0 : 1

  network_endpoint_group = var.neg_name
  ip_address             = var.ip_address
  zone                   = var.zone
  instance               = var.instance_name
  project                = var.project_id
}


