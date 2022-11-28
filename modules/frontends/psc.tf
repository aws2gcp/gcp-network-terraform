# Private Service Connection Publishing (Internal LB only)
resource "google_compute_service_attachment" "default" {
  count                 = var.create && var.params.psc_name != null ? 1 : 0
  name                  = coalesce(var.params.psc_name, local.name)
  description           = local.description
  region                = var.region
  enable_proxy_protocol = var.params.psc_enable_proxy_protocol
  nat_subnets           = local.psc_nat_subnets
  target_service        = google_compute_forwarding_rule.default[0].id
  connection_preference = local.psc_connection_pref
  dynamic "consumer_accept_lists" {
    for_each = var.params.psc_accept_project_ids != null ? var.params.psc_accept_project_ids : []
    content {
      project_id_or_num = consumer_accept_lists.value
      connection_limit  = 10
    }
  }
  project = var.project_id
}