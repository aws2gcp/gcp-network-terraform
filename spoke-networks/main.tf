# Set the VPC name prefix and subnet information
locals {
  name = "${var.name_prefix}-${var.region}"
  subnets = flatten(concat(
    [for i in range(length(var.main_cidrs)) :
      {
        name           = "${local.name}-subnet${i + 1}"
        private_access = true
        ip_range       = var.main_cidrs[i]
        secondary_ranges = concat(
          # GKE Pods Range
          [{
            name  = "gke-pods"
            range = var.gke_pods_cidrs[i]
          }],
          # GKE Services Ranges
          length(coalesce(var.gke_services_cidrs, [])) > 0 ? [for s in range(0, 29) : {
            name  = format("gke-services-%02s", s)
            range = cidrsubnet(var.gke_services_cidrs[i], var.gke_services_range_length - split("/", var.gke_services_cidrs[i])[1], s)
          }] : [],
        )
        attached_projects = concat(var.subnet_attached_projects, var.attached_projects)
        shared_accounts   = concat(var.subnet_shared_accounts, var.shared_accounts)
      }
    ],
    var.create_proxy_only_subnet == true && var.proxy_only_cidr != null ? [
      {
        # Proxy-only subnet for Application ILBs
        name     = "${local.name}-x-proxy-only"
        ip_range = var.proxy_only_cidr
        purpose  = var.proxy_only_purpose
      }
    ] : [],
    var.psc_prefix_base != null ? [for p in range(var.num_psc_subnets) :
      {
        # Also add PSC subnets
        name     = "${local.name}-x-psc-${format("%02s", p)}"
        ip_range = cidrsubnet(var.psc_prefix_base, var.psc_subnet_length - split("/", var.psc_prefix_base)[1], p)
        purpose  = var.psc_purpose
      }
    ] : []
  ))
  cloud_routers = [
    {
      name    = local.name
      bgp_asn = var.cloud_router_bgp_asn
    }
  ]
  cloud_nats = [
    {
      name              = local.name
      cloud_router_name = local.name
      num_static_ips    = var.cloud_nat_num_static_ips
      min_ports_per_vm  = var.cloud_nat_min_ports_per_vm
      max_ports_per_vm  = var.cloud_nat_max_ports_per_vm
      log_type          = var.cloud_nat_log_type
    }
  ]
  routes = [for i, v in var.routes :
    {
      name        = "${v.name}-${local.name}"
      description = v.description
      priority    = coalesce(v.priority, 1000)
      dest_ranges = v.dest_ranges
    }
  ]
  ip_ranges = [
    {
      name     = "servicenetworking-${local.name}"
      ip_range = var.servicenetworking_cidr
    },
    {
      name     = "netapp-cv-${local.name}"
      ip_range = var.netapp_cidr
    }
  ]
  service_connections = [
    {
      name      = "service-networking"
      service   = "servicenetworking.googleapis.com"
      ip_ranges = ["servicenetworking-${local.name}"]
    },
    {
      name      = "netapp-cv"
      service   = "cloudvolumesgcp-api-network.netapp.com"
      ip_ranges = ["netapp-cv-${local.name}"]
    }
  ]
}

# Create VPC network and related resources
module "vpc-network" {
  source              = "../vpc-network"
  project_id          = var.project_id
  network_name        = local.name
  region              = var.region
  subnets             = local.subnets
  cloud_routers       = local.cloud_routers
  cloud_nats          = local.cloud_nats
  routes              = local.routes
  ip_ranges           = local.ip_ranges
  service_connections = local.service_connections
}

# Generate
resource "random_string" "ike_psks" {
  for_each = { for i, v in range(0, 2) : i => v }
  length   = 20
  special  = false
}

# Select random IPs for the Tunnel interior IP addresses
resource "random_integer" "tunnel_third_octet" {
  min = 10
  max = 253
}
resource "random_integer" "tunnel_fourth_octet_base" {
  min = 0
  max = 31
}

locals {
  tunnel_third_octet       = random_integer.tunnel_third_octet.result
  tunnel_fourth_octet_base = random_integer.tunnel_fourth_octet_base.result * 8
  cloud_vpn_gateways       = [{ name = local.name }]
  local_vpns = [{
    name                            = "${local.name}-${var.hub_vpc.network_name}"
    peer_bgp_asn                    = var.hub_vpc.bgp_asn
    cloud_router                    = one(local.cloud_routers).name
    cloud_vpn_gateway               = one(local.cloud_vpn_gateways).name
    peer_gcp_vpn_gateway_project_id = coalesce(var.hub_vpc.project_id, var.project_id)
    peer_gcp_vpn_gateway            = "${var.hub_vpc.network_name}-${var.region}"
    advertised_ip_ranges            = [for i, v in var.main_cidrs : { range = v }]
    tunnels = [for i in range(0, 2) : {
      ike_psk             = random_string.ike_psks[i].result
      cloud_router_ip     = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4) + 1}/30"
      peer_bgp_ip         = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4) + 2}"
      advertised_priority = 100 + i
    }]
    create = true
  }]
}
# Create VPN connection to Hub
module "vpn-to-hub" {
  source             = "../hybrid-networking"
  project_id         = var.project_id
  network_name       = local.name
  region             = var.region
  cloud_vpn_gateways = local.cloud_vpn_gateways
  vpns               = local.local_vpns
  depends_on         = [module.vpc-network]
}

locals {
  remote_vpn_tunnels = [{
    name                            = local.name
    project_id                      = coalesce(var.hub_vpc.project_id, var.project_id)
    cloud_router                    = "${var.hub_vpc.network_name}-${var.region}"
    cloud_vpn_gateway               = "${var.hub_vpc.network_name}-${var.region}"
    peer_gcp_vpn_gateway_project_id = var.project_id
    peer_gcp_vpn_gateway            = one(local.cloud_vpn_gateways).name
    peer_bgp_asn                    = one(local.cloud_routers).bgp_asn
    advertised_ip_ranges            = [for i, v in var.hub_vpc.advertised_ip_ranges : { range = v }]
    tunnels = [for i in range(0, 2) : {
      ike_psk             = random_string.ike_psks[i].result
      cloud_router_ip     = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4) + 2}/30"
      peer_bgp_ip         = "169.254.${local.tunnel_third_octet}.${local.tunnel_fourth_octet_base + (i * 4) + 1}"
      advertised_priority = 100 + i
    }]
    create = true
  }]
}

# Create VPN on the Hub side
module "vpn-to-spoke" {
  source       = "../hybrid-networking"
  project_id   = var.hub_vpc.project_id
  network_name = var.hub_vpc.network_name
  region       = var.region
  vpns         = local.remote_vpn_tunnels
  depends_on   = [module.vpn-to-hub]
}
