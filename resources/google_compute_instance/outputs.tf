output "names" { value = google_compute_instance.default.*.name }
output "zones" { value = google_compute_instance.default.*.zone }
output "self_links" { value = google_compute_instance.default.*.self_link }
output "internal_ips" { value = google_compute_instance.default.*.network_interface.0.network_ip }
output "external_ips" { value = length(var.nat_ips) > 0 ? google_compute_instance.default.*.network_interface.0.access_config.0.nat_ip : [] }
