output "dns_zones" {
  value = {
    for k, v in local.network_firewall_policies : k => {
      #dns_name     = google_dns_managed_zone.default[k].dns_name
      #name_servers = google_dns_managed_zone.default[k].name_servers
      #visibiltiy   = v.visibility
    }
  }
}