#output "id" { value = google_compute_forwarding_rule.default.id }
#output "service_name" { value = google_compute_forwarding_rule.default.service_name }
#output "self_link" { value = google_compute_forwarding_rule.default.self_link }
output "ids" { value = google_compute_forwarding_rule.default.*.id }
output "service_names" { value = google_compute_forwarding_rule.default.*.service_name }
output "self_links" { value = google_compute_forwarding_rule.default.*.self_link }
