locals {
  routes_0 = [for i, v in coalesce(var.routes, []) : merge(v, {
    create        = coalesce(v.create, true)
    project_id    = coalesce(v.project_id, var.project_id)
    name          = replace(coalesce(v.name, "route-${i}"), "_", "-")
    next_hop_type = can(regex("^[1-2]", v.next_hop)) ? "ip" : "instance"
    #dest_ranges   = coalesce(v.dest_ranges, [v.dest_range], [])
  })]
  routes = flatten(concat(
    [for i, v in local.routes_0 : [
      for r, dest_range in coalesce(v.dest_ranges, []) : merge(v, {
        name       = "${v.name}-${r}"
        key        = "${v.project_id}::${v.name}::${r}"
        dest_range = dest_range
      })
    ]],
    [for i, v in local.routes_0 : merge(v, {
      key = "${v.project_id}::${v.name}"
    }) if v.dest_range != null]
  ))
}

# Static Routes
resource "google_compute_route" "default" {
  for_each               = { for i, v in local.routes : v.key => v if v.create }
  project                = var.project_id
  network                = google_compute_network.default.name
  name                   = each.value.name
  description            = each.value.description
  dest_range             = each.value.dest_range
  priority               = each.value.priority
  tags                   = each.value.instance_tags
  next_hop_gateway       = each.value.next_hop == null ? "default-internet-gateway" : null
  next_hop_ip            = each.value.next_hop_type == "ip" ? each.value.next_hop : null
  next_hop_instance      = each.value.next_hop_type == "instance" ? each.value.next_hop : null
  next_hop_instance_zone = each.value.next_hop_type == "instance" ? each.value.next_hop_zone : null
}
