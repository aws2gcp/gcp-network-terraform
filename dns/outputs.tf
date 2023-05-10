output "dns_zones" {
  value = {
    for k, v in local.dns_zones : k => {
      dns_name     = try(google_dns_managed_zone.default[k].dns_name, null)
      name_servers = try(google_dns_managed_zone.default[k].name_servers, null)
      visibiltiy   = v.visibility
    }
  }
}
