locals {
  gen_short_name = var.name == null && var.short_name == null ? true : false
  short_name     = coalesce(var.short_name, local.gen_short_name ? one(random_string.short_name).result : "rule")
  rule_name      = lower(coalesce(var.name, "${local.name_prefix}-${local.short_name}"))
  direction      = upper(coalesce(var.direction, "ingress"))
  action         = var.allow != null ? "ALLOW" : (var.deny != null ? "DENY" : upper(coalesce(var.action, "allow")))
  priority       = coalesce(var.priority, 1000)
  network_name   = coalesce(var.network_name, var.network, "default")
  network_link   = "projects/${var.project_id}/global/networks/${local.network_name}"
  ports          = var.ports != null ? var.ports : (var.port != null ? [var.port] : null)
  protocols      = var.protocols != null ? var.protocols : [local.protocol]
  protocol       = lower(coalesce(var.protocol, var.ports == null && var.port == null ? "all" : "tcp"))
  traffic = [for protocol in local.protocols :
    {
      protocol = protocol
      ports    = local.ports
    }
  ]
  target_tags = var.target_tags != null ? length(var.target_tags) > 0 ? var.target_tags : null : null
  target_sas  = var.target_service_accounts != null ? length(var.target_service_accounts) > 0 ? var.target_service_accounts : null : null
  rule_description_fields = [
    local.network_name,
    local.priority,
    substr(lower(local.direction), 0, 1),
    substr(lower(local.action), 0, 1),
    local.ports != null ? join("-", slice(local.ports, 0, length(local.ports) == 1 ? 1 : 2)) : "allports", # only use first two ports to keep string size small
  ]
  name_prefix = lower(coalesce(var.name_prefix, "fwr-${join("-", local.rule_description_fields)}"))
  disabled    = !var.enforcement ? true : coalesce(var.disabled, false)
  ranges      = var.source_service_accounts == null && var.source_tags == null ? var.range != null ? [var.range] : coalesce(var.ranges, ["169.254.169.254"]) : null
  range_types = toset(coalesce(var.range_types, var.range_type != null ? [var.range_type] : []))
  source_ranges = local.direction == "INGRESS" ? try(coalesce(
    var.ranges,
    length(local.range_types) > 0 ? flatten([for rt in local.range_types : try(data.google_netblock_ip_ranges.default[rt].cidr_blocks, null)]) : null,
    local.ranges,
  ), null) : null
  destination_ranges = local.direction == "EGRESS" ? try(coalesce(
    var.ranges,
    length(local.range_types) > 0 ? flatten([for rt in local.range_types : try(data.google_netblock_ip_ranges.default[rt].cidr_blocks, null)]) : null,
    local.ranges,
  ), null) : null
  source_tags             = local.direction == "INGRESS" ? var.source_tags : null
  source_service_accounts = local.direction == "INGRESS" ? var.source_service_accounts : null
}

resource "random_string" "short_name" {
  count   = local.gen_short_name ? 1 : 0
  length  = 5
  special = false
  upper   = false
}

data "google_netblock_ip_ranges" "default" {
  for_each   = local.range_types
  range_type = each.value
}

resource "google_compute_firewall" "default" {
  project                 = var.project_id
  name                    = local.rule_name
  description             = var.description
  network                 = local.network_link
  priority                = local.priority
  direction               = local.direction
  disabled                = local.disabled
  source_ranges           = local.source_ranges
  source_tags             = local.source_tags
  source_service_accounts = local.source_service_accounts
  destination_ranges      = local.destination_ranges
  dynamic "allow" {
    for_each = var.allow != null ? var.allow : local.action == "ALLOW" ? local.traffic : []
    content {
      protocol = allow.value.protocol != null ? lower(allow.value.protocol) : null
      ports    = try(coalesce(allow.value.ports, var.ports), null)
    }
  }
  dynamic "deny" {
    for_each = var.deny != null ? var.deny : local.action == "DENY" ? local.traffic : []
    content {
      protocol = deny.value.protocol != null ? lower(deny.value.protocol) : null
      ports    = try(coalesce(deny.value.ports, var.ports), null)
    }
  }
  dynamic "log_config" {
    for_each = var.logging ? [true] : []
    content {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
  target_tags             = local.target_tags
  target_service_accounts = local.target_sas
}

