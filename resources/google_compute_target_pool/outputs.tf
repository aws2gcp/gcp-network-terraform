output "names" { value = google_compute_target_pool.default.*.name }
output "ids" { value = google_compute_target_pool.default.*.id }
output "self_links" { value = google_compute_target_pool.default.*.self_link }
