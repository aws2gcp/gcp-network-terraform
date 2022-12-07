resource "google_compute_router" "default" {
  name        = coalesce(var.name, "${var.vpc_network_name}-${var.region}")
  description = var.description
  network     = var.vpc_network_name
  region      = var.region
  project     = var.project_id
  bgp {
    asn               = var.bgp_asn
    advertise_mode    = var.bgp_advertised_ip_ranges != null ? "CUSTOM" : "DEFAULT"
    advertised_groups = var.bgp_advertised_groups
    dynamic "advertised_ip_ranges" {
      for_each = var.bgp_advertised_ip_ranges != null ? var.bgp_advertised_ip_ranges : []
      content {
        range       = advertised_ip_ranges.value.range
        description = advertised_ip_ranges.value.description
      }
    }
    keepalive_interval = var.bgp_keepalive_interval
  }
}
