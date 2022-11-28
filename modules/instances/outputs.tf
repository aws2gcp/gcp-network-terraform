output "instances" {
  value     = local.create_instances ? google_compute_instance.default.* : null
  sensitive = true
}
output "instance_groups" {
  value = local.create_igs ? google_compute_instance_group.default.* : null
}
output "instance_group_ids" {
  value = local.create_igs ? google_compute_instance_group.default.*.id : null
}
output "region" {
  value = var.create ? local.region : null
}
output "create_instances" { value = local.create_instances }
output "distinct_zones" { value = local.distinct_zones }