locals {
  service_connections = { for k, v in var.service_connections : k => merge(v,
    {
      name    = coalesce(v.name, k)
      service = lower(coalesce(v.service, "servicenetworking.googleapis.com"))
    }
  ) }
}
resource "google_service_networking_connection" "default" {
  for_each                = local.service_connections
  reserved_peering_ranges = each.value.ip_ranges
  service                 = each.value.service
  network                 = google_compute_network.default.name
}
