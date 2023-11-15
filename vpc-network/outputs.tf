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
  value = { for i, v in local.subnets : v.key => {
    name     = v.name
    region   = v.region
    ip_range = v.ip_range
    id       = try(google_compute_subnetwork.default[v.key].id, null)
  } if v.create }
}
output "cloud_nats" {
  value = { for i, v in local.cloud_nats : v.key => {
    name = v.name
  } if v.create }
}
