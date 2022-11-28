resource "google_compute_service_attachment" "default" {
  count                 = var.name != null ? 1 : 0
  name                  = var.name
  region                = var.region
  description           = var.description
  enable_proxy_protocol = var.enable_proxy_protocol
  nat_subnets           = local.nat_subnet_ids
  target_service        = var.target_service_id
  connection_preference = var.auto_accept_all_projects == true ? "ACCEPT_AUTOMATIC" : "ACCEPT_MANUAL"
  dynamic "consumer_accept_lists" {
    for_each = var.accept_project_ids != null ? var.accept_project_ids : []
    content {
      project_id_or_num = consumer_accept_lists.value
      connection_limit  = 10
    }
  }
}

locals {
  network_project_id = coalesce(var.network_project_id, var.project_id)
  nat_subnet_ids     = var.nat_subnet_names != null ? [for sn in var.nat_subnet_names : "projects/${local.network_project_id}/regions/${var.region}/subnetworks/${sn}"] : null
}
