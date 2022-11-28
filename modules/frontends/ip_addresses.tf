# Global Frontend Adresses
resource "google_compute_global_address" "default" {
  count        = var.create && local.is_global ? 1 : 0
  name         = local.name
  description  = local.description
  network      = var.params.vpc_network_name
  address      = var.params.ip_address
  address_type = local.type
  #ip_version   = var.ip_version
  project = var.project_id
}

# Regional Frontend Addresses
resource "google_compute_address" "default" {
  count         = var.create && local.is_regional ? 1 : 0
  name          = local.name
  description   = local.description
  address       = var.params.ip_address
  prefix_length = 0
  address_type  = local.type
  region        = var.region
  subnetwork    = local.type == "INTERNAL" ? local.subnet_id : null
  purpose       = local.purpose
  network_tier  = local.network_tier
  project       = var.project_id
}