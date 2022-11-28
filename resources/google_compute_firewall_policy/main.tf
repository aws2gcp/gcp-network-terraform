resource "google_compute_firewall_policy" "default" {
  parent      = "organizations/12345"
  short_name  = var.name
  description = var.description
}
