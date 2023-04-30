

# Firewall rules
module "firewall_rules" {
  source       = "../firewall-rule/"
  for_each     = var.firewall_rules
  project_id   = var.project_id
  name         = each.key
  description  = each.value.description
  network_name = google_compute_network.default.name
  priority     = each.value.priority
  direction    = each.value.direction
  logging      = each.value.logging
  ranges       = each.value.ranges
  action       = each.value.action
}

# VPC Peering Connections
module "peering" {
  source                              = "../vpc-peering/"
  for_each                            = var.peerings
  project_id                          = var.project_id
  name                                = coalesce(each.value.name, each.key)
  our_network_name                    = google_compute_network.default.name
  peer_project_id                     = each.value.peer_project_id
  peer_network_name                   = each.value.peer_network_name
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
}



