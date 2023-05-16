output "id" { value = local.create ? one(google_compute_firewall.default).id : null }
output "name" { value = local.create ? one(google_compute_firewall.default).name : null }
output "self_link" { value = local.create ? one(google_compute_firewall.default).self_link : null }
output "creation_timestamp" { value = local.create ? one(google_compute_firewall.default).creation_timestamp : null }