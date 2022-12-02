output "id" {
  value = var.create && length(google_compute_forwarding_rule.default) > 0 || length(google_compute_global_forwarding_rule.default) > 0 ? coalesce(
    local.is_regional ? one(google_compute_forwarding_rule.default).id : null,
    local.is_global ? one(google_compute_global_forwarding_rule.default).id : null,
  ) : null
}
output "address" {
  value = var.create && length(google_compute_address.default) > 0 || length(google_compute_global_address.default) > 0 ? coalesce(
    local.is_regional ? one(google_compute_address.default).address : null,
    local.is_global ? one(google_compute_global_address.default).address : null,
  ) : null
}
output "type" { value = local.type }
output "protocol" { value = local.protocol }
output "lb_scheme" { value = local.lb_scheme }
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "region" { value = local.is_regional ? var.params.region : null }
output "is_tcp" { value = local.is_tcp }
output "is_http" { value = local.is_http }
output "is_https" { value = local.is_https }
output "create_http" { value = local.create_http }
output "create_https" { value = local.create_https }
output "backend_service_id" { value = local.backend_service_id }
output "subnet_id" { value = local.subnet_id }
output "ssl_certificates" { value = local.ssl_certificates }