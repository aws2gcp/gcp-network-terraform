locals {
  default_allow = [{ protocol = "tcp", ports = ["1-65535"] }, { protocol = "udp", ports = ["1-65535"] }]
  network_firewall_policy_rules = flatten([for k, v in var.network_firewall_policies :
    [for i, rule in coalesce(v.rules, []) : {
      key                     = "${k}-${coalesce(rule.priority, 1000)}"
      policy_key              = k
      project_id              = coalesce(v.project_id, var.project_id)
      rule_name               = coalesce(rule.name, i)
      description             = coalesce(rule.description, "Managed by Terraform")
      priority                = coalesce(rule.priority, 1000)
      direction               = upper(coalesce(rule.direction, "ingress"))
      action                  = lower(coalesce(rule.action, "allow"))
      disabled                = coalesce(rule.disabled, false)
      logging                 = coalesce(rule.logging, false)
      target_service_accounts = null
      allow                   = coalesce(rule.allow, local.default_allow)
      ranges                  = coalesce(rule.ranges, [])
  } if length(coalesce(v.rules, [])) > 0]])
}

resource "google_compute_network_firewall_policy_rule" "default" {
  for_each                = { for v in local.network_firewall_policy_rules : "${v.key}" => v }
  project                 = each.value.project_id
  firewall_policy         = google_compute_network_firewall_policy.default[each.value.policy_key].name
  rule_name               = each.value.rule_name
  priority                = each.value.priority
  description             = each.value.description
  enable_logging          = each.value.logging
  direction               = each.value.direction
  action                  = each.value.action
  disabled                = each.value.disabled
  target_service_accounts = each.value.target_service_accounts
  match {
    src_ip_ranges  = each.value.direction == "INGRESS" ? each.value.ranges : null
    dest_ip_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null
    dynamic "layer4_configs" {
      for_each = each.value.allow
      content {
        ip_protocol = lower(layer4_configs.value.protocol != null ? layer4_configs.value.protocol : "all")
        ports       = layer4_configs.value.ports
      }
    }
  }
}

