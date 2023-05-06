locals {
  network_firewall_policies = { for k, v in var.network_firewall_policies : k => merge(v,
    {
      project_id   = coalesce(v.project_id, var.project_id)
      name         = coalesce(v.name, k)
      description  = coalesce(v.description, "Managed by Terraform")
      associations = coalesce(v.associations, [])
    }
  ) }
}

# Network Firewall Policies
resource "google_compute_network_firewall_policy" "default" {
  for_each    = local.network_firewall_policies
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
}

locals {
  network_firewall_policy_associations = flatten([
    for k, v in local.network_firewall_policies : [
      for i, association in v.associations : {
        key              = "${k}-${i}"
        project_id       = v.project_id
        association_name = association
        network_link     = "projects/${v.project_id}/global/networks/${association}"
        policy_id        = try(google_compute_network_firewall_policy.default[k].id, null)
      }
    ]
  ])
}

# Network Firewall Policy Associations
resource "google_compute_network_firewall_policy_association" "default" {
  for_each          = { for k, v in local.network_firewall_policy_associations : "${v.key}" => v }
  project           = each.value.project_id
  name              = each.value.association_name
  firewall_policy   = each.value.policy_id
  attachment_target = each.value.network_link
}