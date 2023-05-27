locals {
  zones_prefix = "projects/${var.project_id}/zones"
  umigs_with_ids = flatten([for i, v in local.backends : [for ig in coalesce(v.instance_groups, []) : {
    # UMIG id was provided, so we can determine its name and zone by parsing it
    backend_name = v.name
    id           = ig.id
    zone         = element(split("/", ig.id), 3)
    name         = element(split("/", ig.id), 5)
  } if lookup(ig, "id", null) != null]])
  umigs_without_ids = flatten([for i, v in local.backends : [for ig in coalesce(v.instance_groups, []) : {
    # UMIG doesn't have the ID, so we'll figure it out using project, zone, and name
    backend_name = v.name
    name         = lookup(ig, "name", null)
    zone         = ig.zone
    id           = "${local.zones_prefix}/${ig.zone}/instanceGroups/${ig.name}"
    instances    = coalesce(lookup(ig, "instances", null), [])
    port_name    = coalesce(v.port_name, v.port, 80) == 80 ? "http" : "${v.name}-${coalesce(v.port, 80)}"
    port_number  = coalesce(v.port, local.http_port)
    create       = v.create
  } if lookup(ig, "id", null) == null]])
  umig_ids = flatten([for i, v in local.backends : concat(
    [for umig in local.umigs_with_ids : umig.id if umig.backend_name == v.name],
    [for umig in local.umigs_without_ids : umig.id if umig.backend_name == v.name],
  )])
  # If instances were provided, we'll create an unmanaged instance group for them
  new_umigs = flatten([for i, v in local.umigs_without_ids : merge(v, {
    key    = "${v.zone}-${v.name}"
    create = true
  }) if length(v.instances) > 0])
}

# Create new UMIGs if required
resource "google_compute_instance_group" "default" {
  for_each  = { for i, v in local.new_umigs : "${v.key}" => v if v.create }
  project   = var.project_id
  name      = each.value.name
  network   = local.network
  instances = formatlist("${local.zones_prefix}/${each.value.zone}/instances/%s", each.value.instances)
  zone      = each.value.zone
  dynamic "named_port" {
    for_each = local.is_http ? [true] : []
    content {
      name = each.value.port_name
      port = each.value.port_number
    }
  }
}

# Create Named port for HTTP(S) load balancers
locals {
  instance_groups = flatten([
    for i, v in local.backends : [
      for ig_index, ig in coalesce(v.instance_groups, []) : {
        backend_name = v.name
        port_name    = coalesce(v.port_name, v.port, 80) == 80 ? "http" : "${v.name}-${coalesce(v.port, 80)}"
        port_number  = coalesce(v.port, local.http_port)
        ids          = concat(coalesce(v.groups, []), local.umig_ids)
  }] if length(coalesce(v.groups, [])) > 0 || length(coalesce(v.instance_groups, [])) > 0])
  backends_with_new_umigs = toset([for i, v in local.new_umigs : v.backend_name])
  named_ports = flatten([for i, v in local.instance_groups : [for group in v.ids : {
    key          = "${i}-${element(split("/", group), 5)}-${v.port_name}-${v.port_number}"
    group        = group
    name         = v.port_name
    port         = v.port_number
    backend_name = v.backend_name
    create       = !contains(local.backends_with_new_umigs, v.backend_name)
  }] if local.is_http])
}
resource "google_compute_instance_group_named_port" "default" {
  for_each   = { for i, v in local.named_ports : "${v.key}" => v if v.create }
  project    = var.project_id
  group      = each.value.group
  name       = each.value.name
  port       = each.value.port
  depends_on = [google_compute_instance_group.default]
}