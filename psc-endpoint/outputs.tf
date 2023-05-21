output "name" { value = local.name }
output "address" { value = local.create ? one(google_compute_address.default).address : null }
output "address_name" { value = local.create ? one(google_compute_address.default).name : null }
output "psc_connection_id" {
  value = local.create ? one(google_compute_forwarding_rule.default).psc_connection_id : null
}
