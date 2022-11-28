output "id" {
  value = local.create_bucket ? one(concat(
    google_storage_bucket.default.*.id
  )) : null
}
output "name" {
  value = local.create_bucket ? one(concat(
    google_storage_bucket.default.*.name
  )) : null
}
output "self_link" {
  value = local.create_bucket ? one(concat(
    google_storage_bucket.default.*.self_link
  )) : null
}
output "location" { value = var.create ? local.location : null }
output "storage_class" { value = var.create ? local.storage_class : null }
output "versioning" { value = var.create ? var.params.versioning : null }
output "uniform_access_control" { value = var.create ? local.uniform_access_control : null }

