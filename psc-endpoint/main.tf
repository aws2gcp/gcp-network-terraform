locals {
  create             = coalesce(var.create, true)
  name               = coalesce(var.name, "psc-endpoint-${local.region}-${local.target_name}")
  description        = coalesce(var.description, "PSC to ${local.target_id}")
  network_project_id = coalesce(var.network_project_id, var.project_id)
  subnet_prefix      = "projects/${local.network_project_id}/regions/${local.region}/subnetworks"
  subnet_name        = coalesce(var.subnet_name, "default")
  subnet_id          = coalesce(var.subnet_id, "${local.subnet_prefix}/${local.subnet_name}")
  target_name        = var.target_id != null ? lower(element(split("/", var.target_id), 5)) : var.target_name
  target_region      = var.target_id != null ? lower(element(split("/", var.target_id), 3)) : coalesce(var.target_region, var.region)
  target_project_id  = coalesce(var.target_project_id, var.project_id)
  target_id          = coalesce(var.target_id, "projects/${local.target_project_id}/regions/${local.target_region}/serviceAttachments/${local.target_name}")
  region             = coalesce(var.region, local.target_region)
  network_name       = coalesce(var.network_name, "default")
  network_link       = "projects/${local.network_project_id}/global/networks/${local.network_name}"
}

# Create Internal Static IP address on given subnet in given region
resource "google_compute_address" "default" {
  name          = local.name
  description   = local.description
  subnetwork    = local.subnet_id
  region        = local.region
  address_type  = "INTERNAL"
  purpose       = "GCE_ENDPOINT"
  network_tier  = null
  address       = null
  prefix_length = null
  project       = var.project_id
}

# Create Forwarding Rule for the network using generated IP address
resource "google_compute_forwarding_rule" "default" {
  count                 = local.create ? 1 : 0
  name                  = local.name
  network               = local.network_link
  region                = local.region
  ip_address            = google_compute_address.default.self_link
  target                = local.target_id
  subnetwork            = null
  load_balancing_scheme = ""
  all_ports             = false
  allow_global_access   = var.global_access
  project               = var.project_id
}
