
/* Call Hybrid Networking module, passing the cloud_routers variable
module "cloud_routers" {
  source        = "../hybrid-networking/"
  project_id    = var.project_id
  region        = var.region
  network_name  = var.network_name
  cloud_routers = var.cloud_routers
  depends_on    = [google_compute_network.default]
}
*/
