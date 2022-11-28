resource "google_compute_shared_vpc_host_project" "default" {
  count   = var.host_project_id != null ? 1 : 0
  project = var.host_project_id
}
