
locals {
  service_region     = var.target_service_id != null ? lower(element(split("/", var.target_service_id), 3)) : var.region
  region             = coalesce(local.service_region, var.region)
  service_short_name = var.target_service_id != null ? lower(element(split("/", var.target_service_id), 5)) : var.forwarding_rule_name
  name               = coalesce(var.name, "psc-${local.region}-${local.service_short_name}")
  network_project_id = coalesce(var.network_project_id, var.project_id)
  subnet_prefix      = "projects/${local.network_project_id}/regions/${local.region}/subnetworks"
  nat_subnet_ids     = var.nat_subnet_names != null ? [for sn in var.nat_subnet_names : "${local.subnet_prefix}/${sn}"] : null
  fr_prefix          = "projects/${var.project_id}/regions/${local.region}/forwardingRules"
  fr_id              = "${local.fr_prefix}/${var.forwarding_rule_name}"
  target_service_id  = coalesce(var.target_service_id, local.fr_id)
  accept_project_ids = [for i, v in coalesce(var.accept_project_ids, []) : {
    project_id       = v.project_id
    connection_limit = coalesce(v.connection_limit, 10)
  }]
}

resource "google_compute_service_attachment" "default" {
  project               = var.project_id
  name                  = local.name
  region                = local.region
  description           = var.description
  enable_proxy_protocol = var.enable_proxy_protocol
  nat_subnets           = local.nat_subnet_ids
  target_service        = local.target_service_id
  connection_preference = var.auto_accept_all_projects ? "ACCEPT_AUTOMATIC" : "ACCEPT_MANUAL"
  dynamic "consumer_accept_lists" {
    for_each = local.accept_project_ids
    content {
      project_id_or_num = consumer_accept_lists.value.project_id
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
  consumer_reject_lists = []
  domain_names          = []
  reconcile_connections = true
}

