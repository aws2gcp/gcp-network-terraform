output "subnets" {
  value = module.vpc-network.subnets
}
output "cloud_nats" {
  value = module.vpc-network.cloud_nats
}
output "spoke_vpn_tunnels" {
  value = module.vpn-to-hub.vpn_tunnels
}
