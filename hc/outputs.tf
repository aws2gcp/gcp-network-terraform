output "id" {
  value = local.create_hc ? one(concat(
    google_compute_health_check.default.*.id,
    google_compute_region_health_check.default.*.id,
    google_compute_http_health_check.default.*.id,
    google_compute_https_health_check.default.*.id,
  )) : null
}
output "name" {
  value = local.create_hc ? one(concat(
    google_compute_health_check.default.*.name,
    google_compute_region_health_check.default.*.name,
    google_compute_http_health_check.default.*.name,
    google_compute_https_health_check.default.*.name,
  )) : null
}
output "self_link" {
  value = local.create_hc ? one(concat(
    google_compute_health_check.default.*.self_link,
    google_compute_region_health_check.default.*.self_link,
    google_compute_http_health_check.default.*.self_link,
    google_compute_https_health_check.default.*.self_link,
  )) : null
}
output "type" {
  value = local.create_hc ? one(concat(
    google_compute_health_check.default.*.type,
    google_compute_region_health_check.default.*.type,
  )) : null
}
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "is_legacy" { value = local.is_legacy }
output "is_tcp" { value = local.is_tcp }
output "is_http" { value = local.is_http }
output "is_https" { value = local.is_https }
output "is_ssl" { value = local.is_ssl }
output "port" { value = var.port }
output "protocol" { value = local.protocol }
