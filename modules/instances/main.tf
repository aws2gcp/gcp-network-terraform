# Data source to get list of available zones for this region
data "google_compute_zones" "available" {
  count   = local.create_instances && local.find_zones ? 1 : 0
  project = var.project_id
  region  = var.region
}

locals {
  name             = lower(coalesce(var.name, "tf-instance"))
  description      = try(lower(var.description), null)
  create_instances = var.create && var.params.num_instances > 0 ? true : false
  naming_prefix    = "${local.name}-${local.region}"
  #num_instances      = coalesce(var.params.num_instances, 1)
  region             = coalesce(var.region, local.zones != null && length(local.zones) > 0 ? join("-", slice(split("-", local.zones[0]), 0, 2)) : null)
  find_zones         = var.params.zone == null && var.params.zones == null && var.region != null ? true : false
  zones              = local.create_instances && local.find_zones ? data.google_compute_zones.available[0].names : coalesce(var.params.zones, [var.params.zone], [])
  distinct_zones     = distinct(local.zones)
  network_project_id = coalesce(var.params.network_project_id, var.project_id)
  network_prefix     = "projects/${local.network_project_id}/global/networks"
  network_id         = "${local.network_prefix}/${var.params.vpc_network_name}"
  vpc_network_names  = var.params.vpc_network_names != null ? var.params.vpc_network_names : [var.params.vpc_network_name]
  subnet_prefix      = local.region != null ? "projects/${local.network_project_id}/regions/${local.region}/subnetworks" : null
  subnet_id          = try(coalesce(var.params.subnet_id, var.params.subnet_name == null ? null : "${local.subnet_prefix}/${var.params.subnet_name}"), null)
  #nat_interfaces = var.params.nat_interfaces
  create_umigs = var.create && coalesce(var.params.create_umigs, false) ? true : false
  create_migs  = var.create && !local.create_umigs ? true : false
  create_igs   = local.create_migs || local.create_umigs ? true : false
  image        = coalesce(var.params.image, "${var.params.os_project}/${var.params.os}")

}

# Instance Templates

# Basic unmanaged instances
resource "google_compute_instance" "default" {
  count          = local.create_instances ? 1 : 0
  name           = local.naming_prefix
  description    = local.description
  zone           = element(local.zones, count.index)
  machine_type   = var.params.machine_type
  can_ip_forward = var.params.enable_ip_forwarding
  boot_disk {
    initialize_params {
      type  = var.params.boot_disk_type
      size  = var.params.boot_disk_size
      image = local.image
    }
  }
  dynamic "network_interface" {
    for_each = local.vpc_network_names
    content {
      network            = "${local.network_prefix}/${network_interface.value}"
      subnetwork_project = local.network_project_id
      subnetwork         = var.params.subnet_names != null ? var.params.subnet_names[network_interface.key] : var.params.subnet_name
      dynamic "access_config" {
        for_each = var.params.nat_interfaces[network_interface.key] && var.params.nat_ips != null ? [var.params.nat_ips[count.index]] : []
        content {
          nat_ip = var.params.nat_ips[count.index]
        }
      }
    }
  }
  labels = {
    os           = var.params.os
    image        = substr(replace(local.image, "/", "-"), 0, 63)
    machine_type = var.params.machine_type
  }
  tags                    = var.params.network_tags
  metadata_startup_script = var.params.startup_script
  metadata = var.params.ssh_key != null ? {
    instanceSSHKey = var.params.ssh_key
  } : null
  service_account {
    email  = var.params.service_account_email
    scopes = var.params.service_account_scopes
  }
  allow_stopping_for_update = true
  project                   = var.project_id
}


/* Managed Instance Groups
resource "google_compute_instance_group_manager" "default" {
  count              = var.naming_prefix != null ? length(data.google_compute_zones.available.names) : 0
  name               = var.naming_prefix
  base_instance_name = coalesce(var.params.base_instance_name, var.naming_prefix)
  zone               = var.zones != null ? var.zones[count.index] : element(data.google_compute_zones.available.names, count.index)
  version {
    instance_template = var.instance_template
  }
  target_pools = var.target_pools
  target_size  = var.target_size
  auto_healing_policies {
    health_check      = var.healthcheck_id
    initial_delay_sec = var.auto_healing_initial_delay
  }
  project = var.project_id
}
*/

# Unmanaged Instance Groups
resource "google_compute_instance_group" "default" {
  count     = local.create_umigs || local.create_instances ? min(length(google_compute_instance.default.*.zone), length(local.distinct_zones)) : 0
  name      = "${local.naming_prefix}-${count.index + 1}"
  network   = coalesce(var.params.network_id, local.network_id)
  instances = [for k, v in google_compute_instance.default.*.self_link : v if element(local.zones, k) == local.distinct_zones[count.index]]
  zone      = local.distinct_zones[count.index]
  project   = var.project_id
  #dynamic "named_port" {
  #  for_each = local.create_named_port ? [true] : []
  #  content {
  #    name = local.port_name
  #    port = local.port
  #  }
  #}
  #depends_on = [
  #  google_compute_instance.default
  #]
}

/* Named Ports - only used by HTTP(S) LBs
resource "google_compute_instance_group_named_port" "default" {
  #count = var.create && local.port_name != null ? length([for k, v in var.instance_groups : k]) : 0
  #count = var.create && local.port_name != null && var.instance_groups != null ? length(var.params.instance_groups) : 0
  #count = local.port_name != null ? 1 : 0 # local.create_named_port && var.instance_groups != null ? 1 : 0
  count = local.create_named_port ? length(local.instance_group_ids) : 0
  group = local.instance_group_ids[count.index]
  name  = var.params.port_name
  port  = var.params.port
} */

