output "id" {
  value = local.create ? one(concat(
    local.is_cloud_function && local.version == 2 ? google_cloudfunctions2_function.default.*.id : [],
    local.is_cloud_function && local.version == 1 ? google_cloudfunctions_function.default.*.id : [],
    local.is_cloud_run ? google_cloud_run_service.default.*.id : [],
    local.is_app_engine ? google_app_engine_application.default.*.id : []
  )) : null
}
output "name" {
  value = local.create ? one(concat(
    local.is_cloud_function && local.version == 2 ? google_cloudfunctions2_function.default.*.name : [],
    local.is_cloud_function && local.version == 1 ? google_cloudfunctions_function.default.*.name : [],
    local.is_cloud_run ? google_cloud_run_service.default.*.name : [],
    local.is_app_engine ? google_app_engine_application.default.*.name : []
  )) : null
}
output "is_cloud_function" { value = local.is_cloud_function }
output "cloud_function_version" { value = local.is_cloud_function ? local.version : null }
output "is_cloud_run" { value = local.is_cloud_run }
output "is_cloud_app_engine" { value = local.is_app_engine }
output "region" { value = local.create ? var.params.region : null }

