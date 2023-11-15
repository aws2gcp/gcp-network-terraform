locals {
  service_connections_0 = [for i, v in coalesce(var.service_connections, []) : {
    project_id           = coalesce(v.project_id, var.project_id)
    name                 = coalesce(v.name, "service-networking-${i}")
    service              = lower(coalesce(v.service, "servicenetworking.googleapis.com"))
    network_name         = google_compute_network.default.name
    network_id           = google_compute_network.default.id
    import_custom_routes = coalesce(v.import_custom_routes, false)
    export_custom_routes = coalesce(v.export_custom_routes, false)
    ip_ranges            = v.ip_ranges
    create               = coalesce(v.create, true)
  }]
  service_connections = [for i, v in local.service_connections_0 : merge(v, {
    key = "${v.project_id}::${v.network_name}::${v.service}"
  })]
}

resource "google_service_networking_connection" "default" {
  for_each                = { for i, v in local.service_connections : v.key => v if v.create }
  network                 = each.value.network_name
  service                 = each.value.service
  reserved_peering_ranges = each.value.ip_ranges
  depends_on              = [google_compute_global_address.default]
}

# Separate Step to handle route import/export on peering connections
resource "google_compute_network_peering_routes_config" "default" {
  for_each             = { for i, v in local.service_connections : v.key => v if v.create && v.import_custom_routes || v.export_custom_routes }
  peering              = google_service_networking_connection.default[each.key].peering
  network              = each.value.network_name
  import_custom_routes = each.value.import_custom_routes
  export_custom_routes = each.value.export_custom_routes
}
