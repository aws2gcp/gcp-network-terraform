locals {
  network_firewall_policies = { for k, v in var.network_firewall_policies : k => merge(v,
    {
      project_id  = coalesce(v.project_id, var.project_id)
      name        = coalesce(v.name, k)
      description = coalesce(v.description, "Managed by Terraform")
    }
  ) }
}

resource "google_compute_network_firewall_policy" "default" {
  for_each    = local.network_firewall_policies
  project     = each.value.project_id
  name        = each.value.name
  description = each.value.description
}

locals {
  network_firewall_policy_associations = {
    for k, v in local.network_firewall_policies : k => {
      project_id   = v.project_id
      network_link = "projects/${v.project_id}/global/networks/${v.network_name}"
      policy_id    = google_compute_network_firewall_policy.default[k].id
    }
  }
  network_firewall_policies_with_association = {
    for k, v in local.network_firewall_policy_associations : k => merge(v, {
      association_name = coalesce(v.association_name, element(split("/", v.network_link), 4))
      }
  ) }
}

resource "google_compute_network_firewall_policy_association" "default" {
  for_each          = local.network_firewall_policies_with_association
  project           = each.value.project_id
  name              = each.value.association_name
  firewall_policy   = each.value.policy_id
  attachment_target = each.value.network_link
}