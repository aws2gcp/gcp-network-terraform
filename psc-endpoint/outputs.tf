output "name" { value = local.name }
output "address" { value = google_compute_address.default.address }
output "address_name" { value = google_compute_address.default.name }
output "psc_connection_id" {
  value = local.create ? one(google_compute_forwarding_rule.default).psc_connection_id : null
}
