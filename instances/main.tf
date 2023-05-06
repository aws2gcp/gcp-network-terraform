locals {
  instances = { for k, v in var.instances : k => merge(v, {
    project_id             = coalesce(v.project_id, var.project_id)
    region                 = coalesce(v.region, var.region)
    name                   = coalesce(v.name, k)
    zone                   = "us-west1-b"
    machine_type           = coalesce(v.machine_type, "e2-micro")
    os_project             = coalesce(v.os_project, "debian-cloud")
    os                     = coalesce(v.os, "debian-11")
    deletion_protection    = coalesce(v.deletion_protection, false)
    network_names          = [var.network_name]
    subnet_id              = "projects/${var.project_id}/regions/${v.region}/subnetworks/${v.subnet_name}"
    service_account_scopes = ["cloud-platform"]
    image                  = "debian-cloud/debian-11"
  }) }
  zones_list = {
    us-central   = ["b", "c", "a", "f"]
    us-east1     = ["b", "c", "d"]
    europe-west1 = ["b", "c", "d"]
  }
}
resource "google_compute_instance" "default" {
  for_each            = local.instances
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
      image = each.value.image
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
  labels = {
    os           = each.value.os
    machine_type = each.value.machine_type
  }
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

