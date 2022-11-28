resource "google_compute_target_pool" "default" {
  count            = length(var.instances) > 0 ? 1 : 0
  project          = var.project_id
  name             = var.name
  region           = var.region
  instances        = var.instances
  health_checks    = var.healthcheck_names
  session_affinity = var.affinity_type
}
