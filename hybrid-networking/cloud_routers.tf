locals {
  cloud_routers_0 = [for i, v in var.cloud_routers : merge(v, {
    create                 = coalesce(v.create, true)
    project_id             = coalesce(v.project_id, var.project_id)
    description            = coalesce(v.description, "Managed by Terraform")
    region                 = coalesce(v.region, var.region)
    network_name           = coalesce(v.network_name, var.network_name, "default")
    bgp_asn                = coalesce(v.bgp_asn, 64512)
    bgp_keepalive_interval = coalesce(v.bgp_keepalive_interval, 20)
    advertised_groups      = coalesce(v.advertised_groups, [])
    advertised_ip_ranges   = coalesce(v.advertised_ip_ranges, [])
  })]
  cloud_routers_1 = [for i, v in local.cloud_routers_0 : merge(v, {
    name           = coalesce(v.name, "rtr-${v.network_name}-${i}")
    advertise_mode = length(v.advertised_ip_ranges) > 0 ? "CUSTOM" : "DEFAULT"
  })]
  cloud_routers = [for i, v in local.cloud_routers_1 : merge(v, {
    key = "${v.project_id}-${v.region}-${v.name}"
  })]
}

# Cloud Routers
resource "google_compute_router" "default" {
  for_each    = { for k, v in local.cloud_routers : v.key => v if v.create }
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
