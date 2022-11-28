output "id" {
  description = "ID for this Network Endpoint Group"
  value = local.create_neg ? one(concat(
    google_compute_global_network_endpoint_group.default.*.id,
    google_compute_region_network_endpoint_group.default.*.id,
  )) : null
}
output "name" {
  description = "Name for this Network Endpoint Group"
  value = local.create_neg ? one(concat(
    google_compute_global_network_endpoint_group.default.*.name,
    google_compute_region_network_endpoint_group.default.*.name,
  )) : null
}
output "self_link" {
  description = "Self Link for this Network Endpoint Group"
  value = local.create_neg ? one(concat(
    google_compute_global_network_endpoint_group.default.*.self_link,
    google_compute_region_network_endpoint_group.default.*.self_link,
  )) : null
}
output "is_global" { value = local.is_global }
output "is_regional" { value = local.is_regional }
output "region" { value = local.is_regional ? var.region : null }
output "is_ineg" { value = local.is_ineg }
output "is_sneg" { value = local.is_sneg }
output "neg_type" { value = local.neg_type }