locals {
  cloud_routers = { for k, v in var.cloud_routers : k => {
    project_id             = coalesce(v.project_id, var.project_id)
    name                   = coalesce(v.name, k)
    description            = coalesce(v.description, "Managed by Terraform")
    region                 = coalesce(v.region, var.region)
    network_name           = coalesce(v.network_name, var.network_name, "default")
    bgp_asn                = coalesce(v.bgp_asn, 64512)
    bgp_keepalive_interval = coalesce(v.bgp_keepalive_interval, 20)
    advertise_mode         = length(coalesce(v.advertised_ip_ranges, [])) > 0 ? "CUSTOM" : "DEFAULT"
    advertised_groups      = coalesce(v.advertised_groups, [])
    advertised_ip_ranges   = coalesce(v.advertised_ip_ranges, [])
  } }
}

# Cloud Routers
resource "google_compute_router" "default" {
  for_each    = local.cloud_routers
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  network     = each.value.network_name
  bgp {
    asn                = each.value.bgp_asn
    keepalive_interval = each.value.bgp_keepalive_interval
    advertise_mode     = each.value.advertise_mode
    advertised_groups  = each.value.advertised_groups
    dynamic "advertised_ip_ranges" {
      for_each = each.value.advertised_ip_ranges
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
  }
}
