# DNS Zones
module "dns_zones" {
  source              = "../resources/google_dns_managed_zone"
  for_each            = var.dns_zones
  project_id          = var.project_id
  name                = each.key
  description         = each.value.description
  dns_name            = each.value.dns_name
  visibility          = each.value.visibility
  visible_networks    = each.value.visibility == "public" ? [] : coalesce(each.value.visible_networks, [var.vpc_network_name])
  peer_project_id     = each.value.peer_project_id
  peer_network_name   = each.value.peer_network_name
  target_name_servers = each.value.target_name_servers
  logging             = each.value.logging
}

# DNS Policies
module "dns_policies" {
  source              = "../resources/google_dns_policy"
  for_each            = var.dns_policies
  project_id          = var.project_id
  name                = each.key
  description         = each.value.description
  logging             = each.value.logging
  target_name_servers = {}
}

# DNS records
module "dns_records" {
  source     = "../resources/google_dns_record_set"
  for_each   = var.dns_zones
  project_id = var.project_id
  zone_name  = each.key
  dns_name   = module.dns_zones[each.key].dns_name
  records    = coalesce(each.value.records, [])
}


