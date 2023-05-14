output "network_name" {
  value = google_compute_network.default.name
}
output "network_id" {
  value = google_compute_network.default.id
}
output "network_self_link" {
  value = google_compute_network.default.self_link
}
output "subnets" {
  value = { for k, v in local.subnets : k => {
    name     = v.name
    region   = v.region
    ip_range = v.ip_range
  } }
}
output "cloud_nats" {
  value = { for k, v in local.cloud_nats : k => {
    name = v.name
    }
  }
}
