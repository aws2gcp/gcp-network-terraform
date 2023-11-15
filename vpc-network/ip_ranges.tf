locals {
  ip_ranges_0 = [for i, v in coalesce(var.ip_ranges, []) : {
    create        = coalesce(v.create, true)
    project_id    = coalesce(v.project_id, var.project_id)
    name          = coalesce(v.name, "ip-range-${i}")
    description   = v.description
    ip_version    = null
    address       = element(split("/", v.ip_range), 0)
    prefix_length = element(split("/", v.ip_range), 1)
    address_type  = "INTERNAL"
    purpose       = "VPC_PEERING"
    network_name  = google_compute_network.default.name
  }]
  ip_ranges = [for i, v in local.ip_ranges_0 : merge(v, {
    key = "${v.project_id}::${v.network_name}::${v.name}"
  })]
}

resource "google_compute_global_address" "default" {
  for_each      = { for i, v in local.ip_ranges : v.key => v if v.create }
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
