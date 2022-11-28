resource "google_vpc_access_connector" "default" {
  provider      = google-beta
  name          = var.name
  network       = var.subnet_name == null ? var.vpc_network_name : null
  region        = var.region
  ip_cidr_range = var.cidr_range
  dynamic "subnet" {
    for_each = var.subnet_name != null && var.cidr_range == null ? [0] : []
    content {
      name       = var.subnet_name
      project_id = local.network_project_id
    }
  }
  min_instances = var.min_instances
  max_instances = var.max_instances
  machine_type  = var.machine_type
}

locals {
  network_project_id = coalesce(var.network_project_id, var.project_id)
}
