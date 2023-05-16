locals {
  service_connections = { for k, v in var.service_connections : k =>
    {
      ip_ranges            = [for v in v.ip_ranges : coalesce(try(local.ip_ranges[v].name), v)]
      service              = lower(coalesce(v.service, "servicenetworking.googleapis.com"))
      network_name         = google_compute_network.default.name
      network_id           = google_compute_network.default.id
      import_custom_routes = coalesce(v.import_custom_routes, false)
      export_custom_routes = coalesce(v.export_custom_routes, false)
      create               = coalesce(v.create, true)
    }
  }
}
resource "google_service_networking_connection" "default" {
  for_each                = { for k, v in local.service_connections : k => v if v.create }
  reserved_peering_ranges = each.value.ip_ranges
  service                 = each.value.service
  network                 = each.value.network_id
  depends_on              = [google_compute_global_address.default]
}

# Separate Step to handle route import/export on peering connections
resource "google_compute_network_peering_routes_config" "default" {
  for_each             = { for k, v in local.service_connections : k => v if v.create && v.import_custom_routes || v.export_custom_routes }
  peering              = google_service_networking_connection.default[each.key].peering
  network              = each.value.network_name
  import_custom_routes = each.value.import_custom_routes
  export_custom_routes = each.value.export_custom_routes
}
