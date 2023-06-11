locals {
  routes_0 = [for i, v in var.routes : merge(v, {
    create        = coalesce(v.create, true)
    project_id    = coalesce(v.project_id, var.project_id)
    next_hop_type = can(regex("^[1-2]", v.next_hop)) ? "ip" : "instance"
  })]
  routes = flatten([
    for i, v in local.routes_0 : [
      for r, dest_range in coalesce(v.dest_ranges, []) : merge(v, {
        key        = "${i}-${r}"
        dest_range = dest_range
      })
    ]
  ])

}

# Static Routes
resource "google_compute_route" "default" {
  for_each               = { for i, v in local.routes : "${v.key}" => v if v.create }
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
