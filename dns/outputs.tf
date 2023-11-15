output "dns_zones" {
  value = {
    for k, v in local.dns_zones : v.key => {
      dns_name     = try(google_dns_managed_zone.default[k].dns_name, null)
      name_servers = try(google_dns_managed_zone.default[k].name_servers, null)
      visibiltiy   = v.visibility
    } if v.create
  }
}
output "dns_policies" {
  value = {
    for k, v in local.dns_policies : v.key => {
      name = try(google_dns_policy.default[k].name, null)
    } if v.create
  }
}