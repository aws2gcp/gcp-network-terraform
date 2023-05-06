locals {
  mtu                     = coalesce(var.mtu, 1460)
  routing_mode            = var.enable_global_routing == true ? "GLOBAL" : "REGIONAL"
  auto_create_subnetworks = coalesce(var.auto_create_subnetworks, false)
}

# VPC Network
resource "google_compute_network" "default" {
  project                 = var.project_id
  name                    = var.network_name
  description             = var.description
  mtu                     = local.mtu
  routing_mode            = local.routing_mode
  auto_create_subnetworks = local.auto_create_subnetworks
}
