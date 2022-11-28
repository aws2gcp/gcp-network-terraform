output "ids" { value = google_compute_global_network_endpoint_group.default.*.id }
output "names" { value = google_compute_global_network_endpoint_group.default.*.name }
output "self_links" { value = google_compute_global_network_endpoint_group.default.*.self_link }
output "default_ports" { value = google_compute_global_network_endpoint_group.default.*.default_port }
