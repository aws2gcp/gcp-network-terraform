resource "google_compute_ssl_policy" "default" {
  name            = var.name
  description     = var.description
  profile         = var.profile
  min_tls_version = var.min_tls_version
}
