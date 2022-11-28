# Global HTTP & HTTPS Target Proxy
resource "google_compute_target_http_proxy" "default" {
  count   = var.create && local.is_global && local.create_http ? 1 : 0
  name    = local.name
  url_map = google_compute_url_map.http[0].id
}
resource "google_compute_target_https_proxy" "default" {
  count            = var.create && local.is_global && local.create_https ? 1 : 0
  name             = local.name
  url_map          = google_compute_url_map.https[0].id
  ssl_certificates = local.ssl_certificates
}

# Regional HTTP & HTTPS Target Proxies
resource "google_compute_region_target_http_proxy" "default" {
  count   = var.create && local.is_regional && local.create_http ? 1 : 0
  region  = var.region
  name    = local.name
  url_map = google_compute_region_url_map.http[0].id
}
resource "google_compute_region_target_https_proxy" "default" {
  count            = var.create && local.is_regional && local.create_https ? 1 : 0
  region           = var.region
  name             = local.name
  url_map          = google_compute_region_url_map.https[0].id
  ssl_certificates = local.ssl_certificates
}
