locals {
  subnets = { for k, v in var.subnets : k => merge(v,
    {
      name                 = coalesce(v.name, k)
      purpose              = upper(coalesce(v.purpose, "PRIVATE"))
      private_access       = coalesce(v.private_access, var.defaults.subnet_private_access)
      aggregation_interval = coalesce(v.log_aggregation_interval, var.defaults.subnet_log_aggregation_interval)
      flow_sampling        = coalesce(v.log_sampling_rate, var.defaults.subnet_log_sampling_rate)
      log_metadata         = "INCLUDE_ALL_METADATA"
      flow_logs            = coalesce(v.flow_logs, var.defaults.subnet_flow_logs)
      stack_type           = upper(coalesce(v.stack_type, var.defaults.subnet_stack_type))
    }
  ) }
  subnets_with_type = {
    for k, v in local.subnets : k => merge(v, {
      is_private    = v.purpose == "PRIVATE" ? true : false
      is_proxy_only = contains(["INTERNAL_HTTPS_LOAD_BALANCER", "REGIONAL_MANAGED_PROXY"], v.purpose) ? true : false
    })
  }
}

resource "google_compute_subnetwork" "default" {
  for_each                 = local.subnets_with_type
  project                  = var.project_id
  network                  = google_compute_network.default.name
  name                     = each.value.name
  description              = each.value.description
  region                   = each.value.region
  stack_type               = each.value.is_private ? each.value.stack_type : null
  ip_cidr_range            = each.value.ip_range
  purpose                  = each.value.purpose
  role                     = each.value.is_proxy_only ? upper(coalesce(each.value.role, "active")) : null
  private_ip_google_access = each.value.is_private ? each.value.private_access : false
  dynamic "log_config" {
    for_each = each.value.flow_logs && each.value.is_private ? [true] : []
    content {
      aggregation_interval = each.value.aggregation_interval
      flow_sampling        = each.value.flow_sampling
      metadata             = each.value.log_metadata
      metadata_fields      = []
    }
  }
  dynamic "secondary_ip_range" {
    for_each = coalesce(each.value.secondary_ranges, {})
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value.range
    }
  }
}

