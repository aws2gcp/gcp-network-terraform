output "id" { value = local.create ? one(google_compute_region_instance_group_manager.default).id : null }
output "name" { value = local.create ? one(google_compute_region_instance_group_manager.default).name : null }
output "self_link" { value = local.create ? one(google_compute_region_instance_group_manager.default).self_link : null }
output "instance_group" { value = local.create ? one(google_compute_region_instance_group_manager.default).instance_group : null }
output "list_managed_instances_results" { value = local.create ? one(google_compute_region_instance_group_manager.default).list_managed_instances_results : null }
