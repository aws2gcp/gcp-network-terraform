locals {
  vpc_access_connectors_0 = [for i, v in var.vpc_access_connectors : merge(v, {
    project_id     = coalesce(v.project_id, var.project_id)
    name           = coalesce(v.name, "connector-${i}")
    region         = coalesce(v.region, var.region)
    network        = v.subnet_name == null ? google_compute_network.default.name : null
    min_throughput = coalesce(v.min_throughput, 200)
    max_throughput = coalesce(v.max_throughput, 1000)
    min_instances  = coalesce(v.min_instances, 2)
    max_instances  = coalesce(v.max_instances, 10)
    machine_type   = coalesce(v.machine_type, "e2-micro")
    create         = coalesce(v.create, true)
  })]
  vpc_access_connectors = [for i, v in local.vpc_access_connectors_0 : merge(v, {
    key = "${v.project_id}-${v.region}-${v.name}"
  })]
}

# Serverless VPC Access Connectors
resource "google_vpc_access_connector" "default" {
  for_each      = { for k, v in local.vpc_access_connectors : v.key => v if v.create }
  project       = var.project_id
  name          = each.value.name
  network       = each.value.network
  region        = each.value.region
  ip_cidr_range = each.value.cidr_range
  dynamic "subnet" {
    for_each = each.value.subnet_name != null && each.value.cidr_range == null ? [true] : []
    content {
      name       = each.value.subnet_name
      project_id = coalesce(each.value.network_project_id, var.project_id)
    }
  }
  min_throughput = each.value.min_throughput
  max_throughput = each.value.max_throughput
  min_instances  = each.value.min_instances
  max_instances  = each.value.max_instances
  machine_type   = each.value.machine_type
  depends_on     = [google_compute_subnetwork.default]
}
