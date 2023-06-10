

/* Firewall rules
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

*/