resource "google_compute_network_endpoint_group" "default" {
  name    = var.name
  network = var.vpc_network_name
  zone    = var.zone
}
