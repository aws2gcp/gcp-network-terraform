locals {
  cloud_vpn_gateways = { for k, v in var.cloud_vpn_gateways : k => {
    create       = coalesce(v.create, true)
    project_id   = coalesce(v.project_id, var.project_id)
    name         = coalesce(v.name, k)
    network_name = coalesce(v.network_name, var.network_name, "default")
    region       = coalesce(v.region, var.region)
  } }
}

# Cloud HA VPN Gateway
resource "google_compute_ha_vpn_gateway" "default" {
  for_each   = { for k, v in local.cloud_vpn_gateways : k => v if v.create }
  project    = each.value.project_id
  name       = each.value.name
  network    = each.value.network_name
  region     = each.value.region
  depends_on = [google_compute_router.default]
}