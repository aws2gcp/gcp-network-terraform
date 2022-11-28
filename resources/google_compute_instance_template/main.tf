resource "google_compute_instance_template" "default" {
  count          = var.name_prefix == null ? 0 : 1
  name_prefix    = var.name_prefix
  description    = var.description
  project        = var.project_id
  machine_type   = var.machine_type
  can_ip_forward = var.enable_ip_forwarding
  disk {
    source_image = coalesce(var.image, "${local.os_project}/${local.os}")
    auto_delete  = var.disk_auto_delete
    boot         = var.disk_boot
  }
  network_interface {
    network            = var.vpc_network_name
    subnetwork_project = local.network_project_id
    subnetwork         = local.subnet_id
  }
  labels = {
    os           = var.os
    image        = var.image != null ? substr(replace(var.image, "/", "-"), 0, 63) : null
    machine_type = var.machine_type
  }
  tags                    = var.network_tags
  metadata_startup_script = var.startup_script
  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
}

locals {
  network_project_id = coalesce(var.network_project_id, var.project_id)
  subnet_id          = "projects/${local.network_project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  os_project         = coalesce(var.os_project, "debian-cloud")
  os                 = coalesce(var.os, "debian-11")
}

