locals {
  create                   = coalesce(var.create, true)
  create_instance_template = local.create && var.instance_template_name == null ? true : false
  network_project_id       = coalesce(var.network_project_id, var.project_id)
  subnet_id                = "projects/${local.network_project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  os                       = coalesce(var.os, "debian-11")
  os_projects = {
    debian = "debian-cloud"
    ubuntu = "ubuntu-os-cloud"
    centos = "centos-cloud"
    rhel   = "rhel-cloud"
  }
  os_project = coalesce(
    var.os_project,
    lookup(local.os_projects, split("-", local.os)[0], null),
    var.image != null ? lookup(local.os_projects, split("-", var.image)[0], null) : null,
    "debian-cloud" # default to debian
  )
  default_metadata = {
    enable-osconfig         = "true"
    enable-guest-attributes = "true"
  }
  metadata = merge(local.default_metadata, var.metadata, var.ssh_key != null ? { instanceSSHKey = var.ssh_key } : {})
  labels = coalesce(var.labels, {})
}

# Instance Template
resource "google_compute_instance_template" "default" {
  count                   = local.create && local.create_instance_template ? 1 : 0
  project                 = var.project_id
  name_prefix             = var.name_prefix
  description             = var.description
  machine_type            = var.machine_type
  labels                  = { for k, v in local.labels : k => lower(replace(v, " ", "_")) }
  tags                    = var.network_tags
  metadata                = local.metadata
  metadata_startup_script = var.startup_script
  can_ip_forward          = var.enable_ip_forwarding
  disk {
    disk_type    = coalesce(var.disk_type, "pd-standard")
    disk_size_gb = coalesce(var.disk_size, 20)
    source_image = coalesce(var.image, "${local.os_project}/${local.os}")
    auto_delete  = var.disk_auto_delete
    boot         = var.disk_boot
  }
  network_interface {
    network            = var.network_name
    subnetwork_project = local.network_project_id
    subnetwork         = local.subnet_id
    queue_count        = 0
  }
  service_account {
    email  = var.service_account_email
    scopes = coalescelist(var.service_account_scopes, ["cloud-platform"])
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}

/* Add required IAM permissions for Ops Agents
resource "google_project_iam_member" "log_writer" {
  count   = var.service_account_email != null ? 1 : 0
  project = var.project_id
  member  = "serviceAccount:${var.service_account_email}"
  role    = "roles/monitoring.logWriter"
}
resource "google_project_iam_member" "metric_writer" {
  count   = var.service_account_email != null ? 1 : 0
  project = var.project_id
  member  = "serviceAccount:${var.service_account_email}"
  role    = "roles/monitoring.metricWriter"
} */

# Get list of available zones for this region
data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

locals {
  default_zones   = [for z in ["b", "c"] : "${var.region}-${z}"]
  hc_prefix       = "projects/${var.project_id}/${var.region != null ? "regions/${var.region}" : "global"}"
  healthcheck_ids = coalesce(var.healthcheck_ids, [try("${local.hc_prefix}/healthChecks/${var.healthcheck_name}", null)])
  autoscaling     = coalesce(var.min_replicas, 0) > 0 || coalesce(var.max_replicas, 0) > 0 ? true : false
  zones           = coalesce(var.zones, data.google_compute_zones.available.names, local.default_zones)
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "default" {
  count                     = local.create ? 1 : 0
  base_instance_name        = coalesce(var.base_instance_name, var.name_prefix)
  project                   = var.project_id
  name                      = "${var.name_prefix}-${var.region}"
  region                    = var.region
  distribution_policy_zones = local.zones
  target_size               = local.autoscaling ? null : coalesce(var.target_size, 2)
  wait_for_instances        = false
  version {
    name              = "${var.name_prefix}-${var.region}-0"
    instance_template = local.create_instance_template ? one(google_compute_instance_template.default).id : var.instance_template_name
  }
  dynamic "auto_healing_policies" {
    for_each = local.healthcheck_ids
    content {
      health_check      = auto_healing_policies.value
      initial_delay_sec = coalesce(var.auto_healing_initial_delay, 300)
    }
  }
  update_policy {
    type                           = upper(coalesce(var.update_type, "opportunistic"))
    minimal_action                 = upper(coalesce(var.update_minimal_action, "restart"))
    most_disruptive_allowed_action = upper(coalesce(var.update_most_disruptive_action, "replace"))
    replacement_method             = upper(coalesce(var.update_replacement_method, "substitute"))
    max_unavailable_fixed          = length(local.zones)
    max_surge_fixed                = length(local.zones)
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [distribution_policy_zones]
  }
  timeouts {
    create = "5m"
    update = "5m"
    delete = "15m"
  }
}

resource "google_compute_region_autoscaler" "default" {
  provider = google
  count    = local.autoscaling && local.create ? 1 : 0
  name     = var.name_prefix
  project  = var.project_id
  region   = var.region
  target   = local.create ? one(google_compute_region_instance_group_manager.default).self_link : null
  autoscaling_policy {
    max_replicas    = coalesce(var.max_replicas, 10)
    min_replicas    = coalesce(var.min_replicas, 1)
    cooldown_period = coalesce(var.cool_down_period, 60)
    mode            = coalesce(var.autoscaling_mode, local.autoscaling ? "ON" : "OFF")
    cpu_utilization {
      target            = coalesce(var.cpu_target, 0.60)
      predictive_method = coalesce(var.cpu_predictive_method, "NONE")
    }
  }
}
