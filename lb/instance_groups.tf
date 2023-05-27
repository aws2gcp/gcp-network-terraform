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
    create       = v.create
  } if lookup(ig, "id", null) == null]])
  umigs = flatten([for i, v in local.backends : {
    backend_name = v.name
    ids = concat(
      [for umig in local.umigs_with_ids : umig.id if umig.backend_name == v.name],
      [for umig in local.umigs_without_ids : umig.id if umig.backend_name == v.name],
    )
  }])
  # If instances were provided, we'll create an unmanaged instance group for them
  new_umigs = flatten([for i, v in local.umigs_without_ids : merge(v, {
    key    = "${v.zone}-${v.name}"
    create = true
  }) if length(v.instances) > 0])
  instance_groups = flatten([for i, v in local.backends : [
    for ig_index, ig in coalesce(v.instance_groups, []) : {
      backend_name = v.name
      ids          = concat(coalesce(v.groups, []), [for umig in local.umigs : umig.ids if umig.backend_name == v.name])
      port_name    = local.is_http ? v.port_name : null
      port_number  = local.is_http ? coalesce(v.port, 80) : null
  }] if v.type == "igs"])
  backends_with_new_umigs = toset([for i, v in local.new_umigs : v.backend_name])
  named_ports = flatten([for i, v in local.instance_groups : [for group in v.ids : {
    key          = "${v.backend_name}-${i}-${v.port_number}"
    group        = group
    name         = coalesce(v.port_name, v.port_number == 80 ? "http" : "${v.backend_name}-${v.port_number}")
    port         = coalesce(v.port_number, local.http_port)
    backend_name = v.backend_name
    create       = !contains(local.backends_with_new_umigs, v.backend_name)
  }] if local.is_http])
}

# Create new UMIGs if required
resource "google_compute_instance_group" "default" {
  for_each  = { for i, v in local.new_umigs : "${v.key}" => v if v.create }
  project   = var.project_id
  name      = each.value.name
  network   = local.network
  instances = formatlist("${local.zones_prefix}/${each.value.zone}/instances/%s", each.value.instances)
  zone      = each.value.zone
  # Also do named ports within the instance group
  dynamic "named_port" {
    for_each = local.is_http ? [for np in local.named_ports : np if np.backend_name == each.value.backend_name] : []
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

# Add Named ports to existing Instance Groups
resource "google_compute_instance_group_named_port" "default" {
  for_each   = { for i, v in local.named_ports : "${v.key}" => v if v.create }
  project    = var.project_id
  group      = each.value.group
  name       = each.value.name
  port       = each.value.port
  depends_on = [google_compute_instance_group.default]
}