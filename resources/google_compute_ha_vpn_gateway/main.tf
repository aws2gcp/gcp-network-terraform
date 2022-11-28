resource "google_compute_ha_vpn_gateway" "default" {
  name    = coalesce(var.name, local.default_name)
  network = var.vpc_network_name
  region  = var.region
  project = var.project_id
}

locals {
  default_name = "${var.vpc_network_name}-${var.region}"
}

