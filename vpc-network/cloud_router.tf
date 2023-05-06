/*
locals {
  cloud_routers = { for k, v in var.cloud_routers : k => merge(v,
    {
      project_id             = coalesce(v.project_id, var.project_id)
      name                   = coalesce(v.name, k)
      description            = coalesce(nat_address.description, "Managed by Terraform")
      region                 = coalesce(v.region, var.region)
      bgp_asn                = coalesce(v.bgp_asn, var.defaults.cloud_router_bgp_asn)
      bgp_keepalive_interval = coalesce(v.bgp_keepalive_interval, var.defaults.cloud_router_bgp_keepalive_interval)
      advertise_mode         = length(coalesce(v.advertised_ip_ranges, [])) > 0 ? "CUSTOM" : "DEFAULT"
    }
  ) }
}

# Cloud Routers
resource "google_compute_router" "default" {
  for_each    = local.cloud_routers
  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  network     = google_compute_network.default.name
  bgp {
    asn               = each.value.bgp_asn
    advertise_mode    = each.value.advertise_mode
    advertised_groups = each.value.advertised_groups
    dynamic "advertised_ip_ranges" {
      for_each = coalesce(each.value.advertised_ip_ranges, [])
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
    keepalive_interval = each.value.bgp_keepalive_interval
  }
}

*/

module "cloud_routers" {
  source        = "../hybrid-networking/"
  project_id    = var.project_id
  network_name  = var.network_name
  cloud_routers = var.cloud_routers
}
