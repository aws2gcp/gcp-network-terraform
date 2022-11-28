output "names" { value = google_compute_instance_template.default.*.name }
output "zones" { value = google_compute_instance_template.default.*.zone }
output "self_links" { value = google_compute_instance_template.default.*.self_link }
output "internal_ips" { value = google_compute_instance_template.default.*.network_interface.0.network_ip }
#output "external_ips" { value = google_compute_instance_template.default.*.network_interface.0.access_config.0.nat_ip }
