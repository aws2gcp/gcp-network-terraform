locals {
  enabled          = var.enabled == false ? false : true
  our_network_name = coalesce(var.our_network_name, "default")
  our_network_uri  = "projects/${var.project_id}/global/networks/${local.our_network_name}"
  peer_project_id  = coalesce(var.peer_project_id, var.project_id)
  peer_network_uri = "projects/${local.peer_project_id}/global/networks/${var.peer_network_name}"
  our_name         = coalesce(var.name, "${local.our_network_name}-${var.peer_network_name}")
  peer_name        = coalesce(var.name, "${var.peer_network_name}-${local.our_network_name}")
}

resource "google_compute_network_peering" "default" {
  count                               = local.enabled ? 1 : 0
  name                                = local.our_name
  network                             = local.our_network_uri
  peer_network                        = local.peer_network_uri
  import_custom_routes                = coalesce(var.import_custom_routes, false)
  export_custom_routes                = coalesce(var.export_custom_routes, false)
  import_subnet_routes_with_public_ip = coalesce(var.import_subnet_routes_with_public_ip, false)
  export_subnet_routes_with_public_ip = coalesce(var.export_subnet_routes_with_public_ip, true)
}

# If both networks are in the same project, we can light up the other side too
resource "google_compute_network_peering" "peer" {
  count                               = local.enabled && var.project_id == local.peer_project_id ? 1 : 0
  name                                = local.peer_name
  network                             = local.peer_network_uri
  peer_network                        = local.our_network_uri
  import_custom_routes                = coalesce(var.export_custom_routes, false)
  export_custom_routes                = coalesce(var.import_custom_routes, false)
  import_subnet_routes_with_public_ip = coalesce(var.import_subnet_routes_with_public_ip, false)
  export_subnet_routes_with_public_ip = coalesce(var.export_subnet_routes_with_public_ip, true)
}

