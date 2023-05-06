locals {
  ip_ranges = { for k, v in var.ip_ranges : k => merge(v,
    {
      project_id    = coalesce(v.project_id, var.project_id)
      name          = coalesce(v.name, k)
      address       = element(split("/", v.ip_range), 0)
      prefix_length = element(split("/", v.ip_range), 1)
      ip_version    = null
      address_type  = "INTERNAL"
      purpose       = "VPC_PEERING"
    }
  ) }
}

resource "google_compute_global_address" "default" {
  for_each      = local.ip_ranges
  project       = var.project_id
  name          = each.value.name
  description   = each.value.description
  ip_version    = each.value.ip_version
  address       = each.value.address
  prefix_length = each.value.prefix_length
  address_type  = each.value.address_type
  purpose       = each.value.purpose
  network       = google_compute_network.default.name
}
