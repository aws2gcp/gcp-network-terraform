output "id" {
  description = "ID for this SSL Certificate"
  value = local.create ? one(concat(
    local.is_global ? google_compute_ssl_certificate.default.*.id : [],
    local.is_regional ? google_compute_region_ssl_certificate.default.*.id : [],
    local.create_google_ssl_certs ? google_compute_managed_ssl_certificate.default.*.id : [],
  )) : null
}
output "name" {
  description = "Name for this SSL Certificate"
  value = local.create ? one(concat(
    local.is_global ? google_compute_ssl_certificate.default.*.name : [],
    local.is_regional ? google_compute_region_ssl_certificate.default.*.name : [],
    local.create_google_ssl_certs ? google_compute_managed_ssl_certificate.default.*.name : [],
  )) : null
}
output "self_link" {
  description = "Self Link for this SSL Certificate"
  value = local.create ? one(concat(
    local.is_global ? google_compute_ssl_certificate.default.*.self_link : [],
    local.is_regional ? google_compute_region_ssl_certificate.default.*.self_link : [],
    local.create_google_ssl_certs ? google_compute_managed_ssl_certificate.default.*.self_link : [],
  )) : null
}
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "upload_ssl_certs" { value = local.upload_ssl_certs }
output "create_self_signed_cert" { value = local.create_self_signed_cert }
output "create_google_ssl_certs" { value = local.create_google_ssl_certs }
output "region" { value = local.is_regional ? var.params.region : null }
