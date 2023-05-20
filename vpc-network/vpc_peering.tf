locals {
  peerings = { for k, v in var.peerings : k => merge(v,
    {
      name            = coalesce(v.name, k)
      peer_project_id = coalesce(v.peer_project_id, v.project_id, var.project_id)
    }
  ) if coalesce(v, true) }
  peerings_with_network_links = { for k, v in local.peerings : k => merge(v,
    {
      peer_network_link = "projects/${v.peer_project_id}/global/networks/${v.peer_network_name}"
    }
  ) }

}

resource "google_compute_network_peering" "default" {
  for_each                            = local.peerings_with_network_links
  name                                = each.value.name
  network                             = google_compute_network.default.id
  peer_network                        = each.value.peer_network_link
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
}

