
output "id" {
  value = var.create ? one(concat(
    google_compute_backend_service.default.*.id,
    google_compute_region_backend_service.default.*.id,
    google_compute_backend_bucket.default.*.id,
  )) : null
}
output "name" {
  value = var.create ? one(concat(
    google_compute_backend_service.default.*.name,
    google_compute_region_backend_service.default.*.name,
    google_compute_backend_bucket.default.*.name,
  )) : null
}
output "region" {
  value = var.create ? one(concat(
    google_compute_region_backend_service.default.*.region,
  )) : null
}
output "type" { value = local.type }
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "is_neg" { value = local.is_neg }
output "is_bucket" { value = local.is_bucket }
output "is_service" { value = local.is_service }
output "neg_name" { value = var.params.neg_name }
output "neg_id" { value = local.is_neg ? local.neg_id : null }
output "bucket_name" { value = local.create_backend_bucket ? var.params.bucket_name : null }
output "instance_group_ids" { value = local.instance_group_ids }
output "balancing_mode" { value = local.balancing_mode }
output "http_lb_scheme" { value = local.is_http ? local.http_lb_scheme : null }
output "protocol" { value = local.protocol }
output "lb_scheme" { value = local.lb_scheme }
output "affinity_type" { value = local.affinity_type }
