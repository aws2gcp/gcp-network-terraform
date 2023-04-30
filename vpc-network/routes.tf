locals {
  routes = { for k, v in var.routes : k => merge(v,
    {
      next_hop_type = can(regex("^[1-2]", v.next_hop)) ? "ip" : "instance"
    }
  ) }
  routes_list = flatten([
    for k, v in local.routes : [
      for i, dest_range in coalesce(v.dest_ranges, []) : merge(v, {
        key        = "${k}-${i}"
        dest_range = dest_range
      })
    ]
  ])

}

# Static Routes
resource "google_compute_route" "default" {
  for_each               = { for route in local.routes_list : "${route.key}" => route }
  project                = var.project_id
  network                = google_compute_network.default.name
  name                   = each.key
  description            = each.value.description
  dest_range             = each.value.dest_range
  priority               = each.value.priority
  tags                   = each.value.instance_tags
  next_hop_gateway       = each.value.next_hop == null ? "default-internet-gateway" : null
  next_hop_ip            = each.value.next_hop_type == "ip" ? each.value.next_hop : null
  next_hop_instance      = each.value.next_hop_type == "instance" ? each.value.next_hop : null
  next_hop_instance_zone = each.value.next_hop_type == "instance" ? each.value.next_hop_zone : null
}
