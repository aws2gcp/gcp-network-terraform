resource "google_compute_instance" "default" {
  count          = coalesce(var.num_instances, length(var.names) > 0 ? length(var.names) : var.name == null ? 0 : 1)
  name           = length(var.names) > 0 ? var.names[count.index] : "${var.name}-${count.index + 1}"
  description    = var.description
  zone           = var.zones != null ? var.zones[count.index] : "${var.region}-${element(lookup(local.zones_list, var.region, ["b", "c", "a"]), count.index)}"
  project        = var.project_id
  machine_type   = var.machine_type
  can_ip_forward = var.enable_ip_forwarding
  boot_disk {
    initialize_params {
      type  = var.boot_disk_type
      size  = var.boot_disk_size
      image = coalesce(var.image, "${local.os_project}/${local.os}")
    }
  }
  dynamic "network_interface" {
    for_each = length(var.vpc_network_names) > 0 ? var.vpc_network_names : [var.vpc_network_name]
    content {
      network            = network_interface.value
      subnetwork_project = local.network_project_id
      subnetwork         = length(var.subnet_names) > 0 ? var.subnet_names[network_interface.key] : local.subnet_id
      dynamic "access_config" {
        for_each = var.nat_interfaces[network_interface.key] == true && length(var.nat_ips) > 0 ? [var.nat_ips[count.index]] : []
        content {
          nat_ip = var.nat_ips[count.index]
        }
      }
    }
  }
  labels = {
    os           = var.os
    image        = var.image != null ? substr(replace(var.image, "/", "-"), 0, 63) : null
    machine_type = var.machine_type
  }
  tags                    = var.network_tags
  metadata_startup_script = var.startup_script
  /*
  metadata_startup_script = templatefile("${path.root}/${var.startup_script}", {
    generatePassword               = true
    sicKey                         = "abcd1234"
    config_path                    = "projects/${var.project_id}/configs/${var.names[count.index]}-config"
    allowUploadDownload            = true
    templateName                   = "cluster_tf"

  })
  */
  metadata = var.ssh_key != null ? {
    instanceSSHKey = var.ssh_key
  } : null
  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }
  allow_stopping_for_update = true
}

locals {
  network_project_id = coalesce(var.network_project_id, var.project_id)
  subnet_id          = "projects/${local.network_project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  zones_list = {
    "us-central"   = ["b", "c", "a", "f"]
    "us-east1"     = ["b", "c", "d"]
    "europe-west1" = ["b", "c", "d"]
  }
  os_project = coalesce(var.os_project, "debian-cloud")
  os         = coalesce(var.os, "debian-10")
}

