locals {
  zones_prefix = "projects/${var.project_id}/zones"
  umigs_with_ids = flatten([for i, v in local.backends : [for ig in coalesce(v.instance_groups, []) : {
    # UMIG id was provided, so we can determine its name and zone by parsing it
    backend_name = v.name
    id           = trimspace(ig.id)
    zone         = element(split("/", ig.id), 3)
    name         = element(split("/", ig.id), 5)
  } if lookup(ig, "id", null) != null]])
  umigs_without_ids = flatten([for i, v in local.backends : [for ig in coalesce(v.instance_groups, []) : {
    # UMIG doesn't have the ID, so we'll figure it out using project, zone, and name
    backend_name = v.name
    name         = lookup(ig, "name", null)
    zone         = trimspace(ig.zone)
    id           = trimspace("${local.zones_prefix}/${ig.zone}/instanceGroups/${ig.name}")
    instances    = coalesce(lookup(ig, "instances", null), [])
    create       = v.create
  } if lookup(ig, "id", null) == null]])
  umigs = flatten([for i, v in local.backends : [
    for umig in concat(local.umigs_with_ids, local.umigs_without_ids) : umig if umig.backend_name == v.name
  ] if v.type == "igs"])
  # If instances were provided, we'll create an unmanaged instance group for them
  new_umigs = flatten([for i, v in local.umigs_without_ids : merge(v, {
    key    = "${v.zone}-${v.name}"
    create = true
  }) if length(v.instances) > 0])
  backend_ports = { for i, v in local.backends : v.name => {
    port_name   = local.is_http ? v.port_name : null
    port_number = local.is_http ? coalesce(v.port, 80) : null
  } }
  instance_groups = [for i, v in local.umigs : {
    id           = v.id
    backend_name = v.backend_name
    name         = v.name
    zone         = v.zone
    instances    = v.instances
    port_name    = local.is_http ? try(local.backend_ports[v.backend_name].port_name, null) : null
    port_number  = local.is_http ? try(local.backend_ports[v.backend_name].port_number, 80) : null
  }]
  named_ports = flatten([for i, v in local.instance_groups : {
    ig_id        = v.id
    key          = "${v.backend_name}-${v.zone}-${v.name}-${v.port_number}"
    name         = coalesce(v.port_name, v.port_number == 80 ? "http" : "${v.backend_name}-${v.port_number}")
    port         = coalesce(v.port_number, local.http_port)
    backend_name = v.backend_name
    new_umig     = contains([for new_umig in local.new_umigs : new_umig.id], v.id) ? true : false
  } if local.is_http])
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
    for_each = [for np in local.named_ports : np if each.value.id == np.ig_id]
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

# Add Named ports to existing Instance Groups
resource "google_compute_instance_group_named_port" "default" {
  for_each   = { for i, v in local.named_ports : "${v.key}" => v if !v.new_umig }
  project    = var.project_id
  group      = each.value.ig_id
  name       = each.value.name
  port       = each.value.port
  depends_on = [google_compute_instance_group.default]
}