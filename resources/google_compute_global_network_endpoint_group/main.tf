resource "google_compute_global_network_endpoint_group" "default" {
  count                 = var.name == null ? 0 : 1
  name                  = var.name
  description           = var.description
  network_endpoint_type = local.ne_type
  default_port          = var.default_port
  project               = var.project_id
}

locals {
  ne_type = var.ne_type == "fqdn" ? "INTERNET_FQDN_PORT" : "INTERNET_IP_PORT"
}
