output "ids" { value = google_compute_region_health_check.default.*.id }
output "names" { value = google_compute_region_health_check.default.*.name }
