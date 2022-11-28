resource "google_compute_http_health_check" "default" {
  count              = var.name == null ? 0 : 1
  name               = var.name
  port               = var.port
  check_interval_sec = var.interval
  timeout_sec        = var.timeout
  project            = var.project_id
}
