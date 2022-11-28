output "id" {
  description = "ID for this SSL Certificate"
  value = local.create ? one(concat(
    google_compute_ssl_certificate.default.*.id,
    google_compute_region_ssl_certificate.default.*.id,
    google_compute_managed_ssl_certificate.default.*.id
  )) : null
}
output "name" {
  description = "Name for this SSL Certificate"
  value = local.create ? one(concat(
    google_compute_ssl_certificate.default.*.name,
    google_compute_region_ssl_certificate.default.*.name,
    google_compute_managed_ssl_certificate.default.*.name
  )) : null
}
output "self_link" {
  description = "Self Link for this SSL Certificate"
  value = local.create ? one(concat(
    google_compute_ssl_certificate.default.*.self_link,
    google_compute_region_ssl_certificate.default.*.self_link,
    google_compute_managed_ssl_certificate.default.*.self_link
  )) : null
}
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "create_self_signed_cert" { value = local.create_self_signed_cert }
output "region" { value = local.is_regional ? var.region : null }
