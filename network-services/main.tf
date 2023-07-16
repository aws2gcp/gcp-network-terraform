

# Create Regional Healthcheck for MIG and ILB
module "healthcheck" {
  source      = "../hc"
  for_each    = var.deployments
  project_id  = var.project_id
  name        = "${var.name_prefix}-${coalesce(each.value.region, each.key)}-${var.ports[0]}"
  description = "Regional Healthcheck for ${var.name_prefix}"
  region      = coalesce(each.value.region, each.key)
  protocol    = "TCP"
  port        = var.ports[0]
  interval    = var.healthcheck_interval
}

# Iterate over deployments and set some variables for Instance Template/MIG/AutoScaler
locals {
  use_autoscaling = coalesce(var.autoscaling_mode, "OFF") == "ON" || coalesce(var.min_replicas, 0) > 0 ? true : false
  existing_igs    = { for k, v in var.deployments : k => v.instance_groups if length(coalesce(v.instance_groups, [])) > 0 }
  deployments = { for k, v in var.deployments : k => merge(v, {
    region                = coalesce(v.region, k)
    base_instance_name    = "${var.name_prefix}-${k}"
    ip_address_name       = coalesce(v.ip_address_name, "${var.name_prefix}-${coalesce(v.region, k)}-ilb")
    forwarding_rule_name  = coalesce(v.forwarding_rule_name, "${var.name_prefix}-${coalesce(v.region, k)}")
    global_access         = coalesce(v.global_access, var.global_access, false)
    ports                 = try(coalesce(v.ports, var.ports), null)
    cpu_target            = coalesce(v.cpu_target, var.cpu_target, 0.6)
    cpu_predictive_method = coalesce(v.cpu_predictive_method, var.cpu_predictive_method, "NONE")
    })
  }
}

# Create Instance Template + Managed Instance Group
module "mig" {
  source                           = "../mig"
  for_each                         = length(local.existing_igs) > 0 ? {} : local.deployments
  project_id                       = var.project_id
  name_prefix                      = var.name_prefix
  base_instance_name               = each.value.base_instance_name
  region                           = each.value.region
  network_name                     = var.network_name
  network_project_id               = var.network_project_id
  subnet_name                      = each.value.subnet_name
  service_account_email            = var.service_account_email
  network_tags                     = var.network_tags
  machine_type                     = var.machine_type
  disk_size                        = var.disk_size
  image                            = var.image
  os_project                       = var.os_project
  os                               = var.os
  labels                           = var.labels
  startup_script                   = var.startup_script
  healthcheck_ids                  = [module.healthcheck[each.key].id]
  update_type                      = "OPPORTUNISTIC"
  distribution_policy_target_shape = "EVEN"
  instance_redistribution_type     = "PROACTIVE"
  update_minimal_action            = "REPLACE"
  target_size                      = local.use_autoscaling ? null : coalesce(each.value.target_size, var.target_size, 2)
  autoscaling_mode                 = local.use_autoscaling ? "ON" : "OFF"
  cpu_target                       = each.value.cpu_target
  cpu_predictive_method            = each.value.cpu_predictive_method
  min_replicas                     = local.use_autoscaling ? coalesce(each.value.min_replicas, var.min_replicas, 2) : null
  max_replicas                     = local.use_autoscaling ? coalesce(each.value.max_replicas, var.max_replicas, 9) : null
  cool_down_period                 = var.cool_down_period
}

# Create Internal TCP/UDP Load Balancer
module "ilb" {
  source               = "../lb"
  for_each             = { for k, v in local.deployments : k => v if v.create_ilb != false }
  project_id           = var.project_id
  name_prefix          = var.name_prefix
  region               = each.value.region
  network_name         = var.network_name
  network_project_id   = var.network_project_id
  subnet_name          = each.value.subnet_name
  ip_address           = each.value.ip_address
  ip_address_name      = each.value.ip_address_name
  forwarding_rule_name = each.value.forwarding_rule_name
  ports                = each.value.ports
  global_access        = each.value.global_access
  psc                  = each.value.psc
  labels               = var.labels
  backends = [
    {
      name            = "${var.name_prefix}-${each.key}"
      description     = "${var.name_prefix} backend service for '${each.key}'"
      groups          = lookup(module.mig, each.key, null) != null ? [module.mig[each.key].instance_group] : null
      instance_groups = each.value.instance_groups
      healthchecks    = [{ name = "${var.name_prefix}-${coalesce(each.value.region, each.key)}-${var.ports[0]}" }]
      affinity_type   = var.affinity_type
    }
  ]
  depends_on = [module.healthcheck]
}

# Enable IAM roles required for Ops Agent
locals {
  ops_agent_iam_members = { for i, v in ["logging.logWriter", "monitoring.metricWriter"] : i => {
    member = "serviceAccount:${var.service_account_email}"
    role   = "roles/${v}"
  } if length(local.existing_igs) < 1 && var.service_account_email != null }
}
resource "google_project_iam_member" "ops_agent" {
  for_each = local.ops_agent_iam_members
  project  = var.project_id
  member   = each.value.member
  role     = each.value.role
}