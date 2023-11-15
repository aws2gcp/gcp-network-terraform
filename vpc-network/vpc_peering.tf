locals {
  peerings_0 = { for k, v in coalesce(var.peerings, []) : k => merge(v,
    {
      name              = coalesce(v.name, k)
      project_id        = coalesce(v.project_id, var.project_id)
      peer_project_id   = coalesce(v.peer_project_id, v.project_id, var.project_id)
      peer_network_name = coalesce(v.peer_network_name, "default")
      create            = coalesce(v.create, true)
    }
  ) }
  peerings = { for k, v in local.peerings_0 : k => merge(v,
    {
      key = "${v.project_id}::${var.network_name}::${v.name}"
      # If peer network link not provided, we can generate it using their project ID and network name
      peer_network_link = coalesce(v.peer_network_link, "projects/${v.peer_project_id}/global/networks/${v.peer_network_name}")
    }
  ) }
}

resource "google_compute_network_peering" "default" {
  for_each                            = { for k, v in local.peerings : v.key => v if v.create }
  name                                = each.value.name
  network                             = google_compute_network.default.id
  peer_network                        = each.value.peer_network_link
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
}

