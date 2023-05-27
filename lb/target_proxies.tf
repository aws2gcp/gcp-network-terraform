locals {
  quic_override = coalesce(var.quic_override, "NONE")
  ssl_policy    = local.is_global && local.is_http ? coalesce(var.ssl_policy_name, one(google_compute_ssl_policy.default).id) : null
}

# Global TCP Proxy
resource "google_compute_target_tcp_proxy" "default" {
  count           = local.create && local.is_global && !local.is_http ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-${lower(local.type)}"
  backend_service = try(lookup(local.backend_ids, var.default_backend, null), null)
}

/* Regional TCP Proxy
resource "google_compute_region_target_tcp_proxy" "default" {
  count           = local.is_regional && !local.is_http ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-${lower(local.type)}"
  backend_service = try(lookup(local.backend_ids, var.default_backend, null), null)
  region          = local.region
} */

# Global HTTP Target Proxy
resource "google_compute_target_http_proxy" "default" {
  count   = local.create && local.is_global && local.is_http && local.enable_http ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-http"
  url_map = one(google_compute_url_map.http).id
}

# Regional HTTP Target Proxy
resource "google_compute_region_target_http_proxy" "default" {
  count   = local.create && local.is_regional && local.is_http && local.enable_http ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-http"
  url_map = one(google_compute_region_url_map.http).id
  region  = local.region
}

# Global HTTPS Target Proxy
resource "google_compute_target_https_proxy" "default" {
  count   = local.create && local.is_global && local.is_http && local.enable_https ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-https"
  url_map = one(google_compute_url_map.https).id
  ssl_certificates = local.use_ssc ? [google_compute_ssl_certificate.default["self-signed"].name] : coalesce(
    var.ssl_cert_names,
    [for i, v in local.certs_to_upload : google_compute_ssl_certificate.default[v.name].id]
  )
  ssl_policy    = local.ssl_policy
  quic_override = local.quic_override
  depends_on    = [google_compute_url_map.https, google_compute_ssl_certificate.default]
}

# Regional HTTPS Target Proxy
resource "google_compute_region_target_https_proxy" "default" {
  count   = local.create && local.is_regional && local.is_http && local.enable_https ? 1 : 0
  project = var.project_id
  name    = "${local.name_prefix}-https"
  url_map = one(google_compute_region_url_map.https).id
  ssl_certificates = local.use_ssc ? [google_compute_region_ssl_certificate.default["self_signed"].name] : [
    for i, v in local.certs_to_upload : google_compute_region_ssl_certificate.default[v.name].id
  ]
  #ssl_policy       = local.ssl_policy
  #quic_override = local.quic_override
  region     = local.region
  depends_on = [google_compute_region_url_map.https, google_compute_region_ssl_certificate.default]
}
