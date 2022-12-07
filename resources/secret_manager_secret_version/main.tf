resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret      = var.secret_id
  secret_data = var.secret_data
}
