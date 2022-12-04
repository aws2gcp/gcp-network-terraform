locals {
  type                  = upper(coalesce(var.params.type, "external"))
  protocol              = upper(coalesce(var.params.protocol, local.use_neg ? "https" : "tcp"))
  is_http               = upper(substr(local.protocol, 0, 4)) == "HTTP" ? true : false
  is_internal           = local.type == "INTERNAL" ? true : false
  is_external           = local.type == "EXTERNAL" ? true : false
  port_name             = local.use_igs && local.is_http && !local.use_neg ? lower(var.params.port_name) : null
  create_named_port     = local.create && local.use_igs && local.is_http && local.port_name != null ? true : false
  ig_blancing_mode      = upper(coalesce(var.params.balancing_mode, "utilization"))
  balancing_mode        = local.use_neg ? "UTILIZATION" : local.protocol == "TCP" ? "CONNECTION" : null
  max_connections       = local.lb_scheme == "INTERNAL" ? var.params.max_connections : null
  capacity_scaler       = endswith(local.lb_scheme, "_MANAGED") ? var.params.capacity_scaler : null
  locality_lb_policy    = endswith(local.lb_scheme, "_MANAGED") ? "ROUND_ROBIN" : null
  max_utilization       = local.use_igs && local.balancing_mode == "UTILIZATION" ? var.params.max_utilization : null
  max_rate_per_instance = local.use_igs && local.balancing_mode == "RATE" ? var.params.max_rate_per_instance : null
  affinity_type         = coalesce(var.params.affinity_type, local.lb_scheme == "INTERNAL" ? "CLIENT_IP_PORT_PROTO" : "NONE")
  lb_scheme             = local.protocol == "TCP" ? local.type : local.is_http ? local.http_lb_scheme : null
  http_lb_scheme        = local.type == "INTERNAL" ? "INTERNAL_MANAGED" : local.external_lb_scheme
  external_lb_scheme    = local.is_regional && !local.is_classic ? "EXTERNAL_MANAGED" : "EXTERNAL"
  timeout               = coalesce(var.params.timeout, 30)
  neg_prefix            = "projects/${var.project_id}/${var.params.neg_region != null ? "regions/${var.params.neg_region}" : "global"}/networkEndpointGroups"
  neg_id                = var.params.neg_name != null ? "${local.neg_prefix}/${var.params.neg_name}" : null
  hc_prefix             = "projects/${var.project_id}/global/healthChecks"
  healthcheck_id        = local.use_healthchecks ? var.params.healthcheck_id : null
  healthcheck_name      = local.use_healthchecks && var.params.healthcheck_name != null ? "${local.hc_prefix}/${var.params.healthcheck_name}" : null
  enable_logging        = coalesce(var.params.enable_logging, false)
  log_sample_rate       = coalesce(var.params.log_sample_rate, 1.0)
  ig_prefix             = "projects/${var.project_id}/zones"
  instance_group_ids    = coalesce(var.params.instance_group_ids, var.params.instance_groups != null ? [for k, v in var.params.instance_groups : "${local.ig_prefix}/${v.zone}/instanceGroups/${k}"] : [])
}

# Named Ports - only used by HTTP(S) LBs
resource "google_compute_instance_group_named_port" "default" {
  count   = local.create_named_port ? length(local.instance_group_ids) : 0
  group   = local.instance_group_ids[count.index]
  port    = var.params.port
  name    = var.params.port_name
  project = var.project_id
}

# Create basic TCP healthcheck if healthcheck name or IDs not provided
module "auto_healthcheck" {
  source = "../healthchecks"
  #create = local.use_healthchecks && local.healthcheck_id == null ? true : false
  count = local.use_healthchecks && local.healthcheck_id == null ? 1 : 0
  name  = "auto-hc-${local.name}-${var.params.port}"
  params = {
    protocol = "tcp"
    port     = var.params.port
    regional = local.is_regional
    region   = var.params.region
  }
  project_id = var.project_id
}

locals {
  healthcheck = local.use_healthchecks ? one(module.auto_healthcheck).id : null
}

# Target Pools
resource "google_compute_target_pool" "default" {
  count  = var.create && var.params.use_target_pools ? 1 : 0
  name   = local.name
  region = var.params.region
  #instances        = var.params.instance_ids
  health_checks    = local.use_healthchecks ? [local.healthcheck] : null
  session_affinity = local.affinity_type
  project          = var.project_id
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  count                 = local.create_backend_service && local.is_global && local.is_external ? 1 : 0
  name                  = local.name
  description           = local.description
  load_balancing_scheme = local.lb_scheme
  port_name             = local.port_name
  protocol              = local.protocol
  health_checks         = local.use_healthchecks ? [local.healthcheck_id] : null
  timeout_sec           = local.timeout
  dynamic "backend" {
    for_each = local.use_neg ? [local.neg_id] : local.instance_group_ids
    content {
      group                 = backend.value
      balancing_mode        = local.balancing_mode
      capacity_scaler       = local.capacity_scaler
      max_utilization       = local.max_utilization
      max_connections       = local.max_connections
      max_rate_per_instance = local.max_rate_per_instance
    }
  }
  dynamic "log_config" {
    for_each = local.enable_logging ? [true] : []
    content {
      enable      = local.enable_logging
      sample_rate = local.log_sample_rate
    }
  }
  locality_lb_policy = local.locality_lb_policy
  session_affinity   = local.affinity_type
  project            = var.project_id
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  count                 = local.create_backend_service && local.is_regional ? 1 : 0
  name                  = local.name
  description           = local.description
  region                = var.params.region
  load_balancing_scheme = local.lb_scheme
  port_name             = local.port_name
  protocol              = local.protocol
  health_checks         = local.use_healthchecks ? [local.healthcheck] : null
  timeout_sec           = local.timeout
  dynamic "backend" {
    for_each = local.use_neg ? [local.neg_id] : local.instance_group_ids
    content {
      group                 = backend.value
      balancing_mode        = local.balancing_mode
      capacity_scaler       = local.capacity_scaler
      max_utilization       = local.max_utilization
      max_connections       = local.max_connections
      max_rate_per_instance = local.max_rate_per_instance
    }
  }
  dynamic "log_config" {
    for_each = local.enable_logging ? [true] : []
    content {
      enable      = local.enable_logging
      sample_rate = local.log_sample_rate
    }
  }
  locality_lb_policy = local.locality_lb_policy
  session_affinity   = local.affinity_type
  project            = var.project_id
}