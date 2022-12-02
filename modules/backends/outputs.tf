
output "id" {
  value = local.create ? one(concat(
    google_compute_backend_service.default.*.id,
    google_compute_region_backend_service.default.*.id,
    google_compute_backend_bucket.default.*.id,
  )) : null
}
output "name" {
  value = local.create ? one(concat(
    google_compute_backend_service.default.*.name,
    google_compute_region_backend_service.default.*.name,
    google_compute_backend_bucket.default.*.name,
  )) : null
}
output "region" {
  value = local.create ? one(concat(
    google_compute_region_backend_service.default.*.region,
  )) : null
}
output "type" { value = local.type }
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "use_neg" { value = local.use_neg }
output "use_bucket" { value = local.use_bucket }
output "use_igs" { value = local.use_igs }
output "use_healtchecks" { value = local.use_healthchecks }
output "neg_name" { value = var.params.neg_name }
output "neg_id" { value = local.use_neg ? local.neg_id : null }
output "healthcheck_id" { value = local.healthcheck_id }
output "bucket_name" { value = local.create_backend_bucket ? var.params.bucket_name : null }
output "instance_group_ids" { value = local.instance_group_ids }
output "balancing_mode" { value = local.balancing_mode }
output "protocol" { value = local.protocol }
output "lb_scheme" { value = local.lb_scheme }
output "affinity_type" { value = local.affinity_type }
