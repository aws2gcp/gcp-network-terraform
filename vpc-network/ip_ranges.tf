locals {
  ip_ranges = { for k, v in var.ip_ranges : k =>
    {
      project_id    = coalesce(v.project_id, var.project_id)
      name          = coalesce(v.name, k)
      description   = v.description
      ip_version    = null
      address       = element(split("/", v.ip_range), 0)
      prefix_length = element(split("/", v.ip_range), 1)
      address_type  = "INTERNAL"
      purpose       = "VPC_PEERING"
      network_name  = google_compute_network.default.name
      create        = coalesce(v.enable, true)
    }
  }
}

resource "google_compute_global_address" "default" {
  for_each      = { for k, v in local.ip_ranges : k => v if v.create }
  project       = var.project_id
  name          = each.value.name
  description   = each.value.description
  ip_version    = each.value.ip_version
  address       = each.value.address
  prefix_length = each.value.prefix_length
  address_type  = each.value.address_type
  purpose       = each.value.purpose
  network       = each.value.network_name
}
