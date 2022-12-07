resource "google_secret_manager_secret" "default" {
  secret_id = var.secret_id
  project   = var.project_id
  replication {
    automatic = true
  }
}
