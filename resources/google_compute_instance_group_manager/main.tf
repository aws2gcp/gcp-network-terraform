resource "google_compute_instance_group_manager" "default" {
  count              = 1
  name               = var.name
  base_instance_name = "app"
  zone               = "${var.region}-${element(lookup(local.zones, var.region, ["b", "c", "a"]), count.index)}"
  version {
    instance_template = var.instance_template
  }
  target_pools = var.target_pools
  target_size  = 2
  auto_healing_policies {
    health_check      = var.auto_healing_health_check
    initial_delay_sec = var.auto_healing_initial_delay
  }
}
locals {
  zones = {
    "us-central"   = ["b", "c", "a", "f"]
    "us-east1"     = ["b", "c", "d"]
    "europe-west1" = ["b", "c", "d"]
  }
}
