output "names" { value = google_compute_instance_group_manager.default.*.name }
output "zones" { value = google_compute_instance_group_manager.default.*.zone }
output "ids" { value = google_compute_instance_group_manager.default.*.id }
output "self_links" { value = google_compute_instance_group_manager.default.*.self_link }
output "statuses" { value = google_compute_instance_group_manager.default.*.status }
