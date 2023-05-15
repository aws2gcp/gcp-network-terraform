locals {
  zones = {
    us-central   = ["b", "c", "a", "f"]
    us-east1     = ["b", "c", "d"]
    europe-west1 = ["b", "c", "d"]
  }
  instances_0 = { for k, v in var.instances : k => merge(v, {
    create                 = coalesce(v.create, true)
    project_id             = coalesce(v.project_id, var.project_id)
    region                 = coalesce(v.region, var.region)
    name                   = coalesce(v.name, k)
    machine_type           = lower(coalesce(v.machine_type, "e2-micro"))
    os_project             = lower(coalesce(v.os_project, "debian-cloud"))
    os                     = lower(coalesce(v.os, "debian-11"))
    deletion_protection    = coalesce(v.deletion_protection, false)
    network_names          = [var.network_name]
    service_account_scopes = ["cloud-platform"]
    image                  = v.image
    labels                 = coalesce(v.labels, {})
    roles                  = coalesce(v.roles, [])
  }) }
  instances = { for k, v in local.instances_0 : k => merge(v, {
    zone      = coalesce(v.zone, "${v.region}-${lookup(local.zones, k, "b")}")
    subnet_id = "projects/${var.project_id}/regions/${v.region}/subnetworks/${v.subnet_name}"
    labels = merge(v.labels, {
      os           = v.os
      machine_type = v.machine_type
    })
  }) }
}
resource "google_compute_instance" "default" {
  for_each            = { for k, v in local.instances : "${v.project_id}-${v.zone}-${v.name}" => v if v.create }
  project             = each.value.project_id
  name                = each.value.name
  description         = each.value.description
  zone                = each.value.zone
  machine_type        = each.value.machine_type
  can_ip_forward      = each.value.enable_ip_forwarding
  deletion_protection = each.value.deletion_protection
  boot_disk {
    initialize_params {
      type  = each.value.boot_disk_type
      size  = each.value.boot_disk_size
      image = coalesce(each.value.image, "${each.value.os_project}/${each.value.os}")
    }
  }
  dynamic "network_interface" {
    for_each = each.value.network_names
    content {
      network            = network_interface.value
      subnetwork_project = each.value.project_id
      subnetwork         = each.value.subnet_id
    }
  }
  labels                  = { for k, v in each.value.labels : k => lower(replace(v, " ", "_")) }
  tags                    = each.value.network_tags
  metadata_startup_script = each.value.startup_script
  metadata = each.value.ssh_key != null ? {
    instanceSSHKey = each.value.ssh_key
  } : null
  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }
  allow_stopping_for_update = true
}

locals {
  instance_roles = flatten([for k, v in local.instances : [
    for i, role in v.roles : [
      for member in role.members : {
        project_id    = v.project_id
        instance_name = v.name
        zone          = v.zone
        role          = startswith(role.role, "roles/") ? role.role : "roles/${role.role}"
        member        = member
        key           = "${v.project_id}-${v.zone}-${v.name}-${i}-${member}"
      }
  ] if v.create]])
}
resource "google_compute_instance_iam_member" "default" {
  for_each      = { for i, v in local.instance_roles : v.key => v }
  project       = each.value.project_id
  instance_name = each.value.instance_name
  zone          = each.value.zone
  role          = each.value.role
  member        = each.value.member
}
