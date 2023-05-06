variable "project_id" {
  description = "Project ID of GCP Project"
  type        = string
  default     = null
}
variable "network_name" {
  description = "Name of VPC Network"
  type        = string
  default     = null
}
variable "region" {
  description = "GCP default region name for all resources"
  type        = string
  default     = null
}
variable "cloud_routers" {
  description = "Cloud Routers attached to this VPC Network"
  type = map(object({
    project_id             = optional(string)
    name                   = optional(string)
    description            = optional(string)
    network_name           = optional(string)
    region                 = string
    bgp_asn                = optional(number)
    bgp_keepalive_interval = optional(number)
    advertised_groups      = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })))
  }))
  default = {}
}
variable "interconnects" {
  description = "Dedicated and Partner Interconnects"
  type = map(object({
    type                 = string
    project_id           = optional(string)
    region               = optional(string)
    cloud_router_name    = optional(string)
    cloud_router_ip      = optional(string)
    bgp_peer_ip          = optional(string)
    peer_bgp_asn         = optional(number)
    advertised_priority  = optional(number)
    advertised_groups    = optional(list(string))
    advertised_ip_ranges = optional(list(string))
    mtu                  = optional(number)
    enable               = optional(bool)
    enable_bfd           = optional(bool)
    bfd_parameters       = optional(list(number))
    circuits = list(object({
      interface_index      = optional(number)
      attachment_name      = optional(string)
      interface_name       = optional(string)
      name                 = optional(string)
      bgp_name             = optional(string)
      description          = optional(string)
      mtu                  = optional(number)
      cloud_router_ip      = optional(string)
      bgp_peer_ip          = optional(string)
      peer_bgp_asn         = optional(number)
      advertised_priority  = optional(number)
      advertised_groups    = optional(list(string))
      advertised_ip_ranges = optional(list(string))
    }))
  }))
  default = {}
}
variable "cloud_vpn_gateways" {
  description = "Map of GCP Cloud VPN Gateways"
  type = map(object({
    project_id   = optional(string)
    name         = optional(string)
    network_name = optional(string)
    region       = optional(string)
  }))
  default = {}
}
variable "peer_vpn_gateways" {
  description = "Map of Peer (External) VPN Gateways"
  type = map(object({
    project_id   = optional(string)
    name         = optional(string)
    description  = optional(string)
    ip_addresses = optional(list(string))
    labels       = optional(map(string))
  }))
  default = {}
}
variable "vpns" {
  description = "Map of HA VPNs"
  type = map(object({
    project_id             = optional(string)
    name                   = optional(string)
    region                 = string
    cloud_vpn_gateway_name = optional(string)
    cloud_router_name      = optional(string)
    peer_vpn_gateway_name  = string
    peer_bgp_asn           = optional(number)
    advertised_priority    = optional(number)
    advertised_groups      = optional(list(string))
    advertised_ip_ranges   = optional(list(string))
    enable_bfd             = optional(bool)
    bfd_multiplier         = optional(number)
    tunnels = list(object({
      name                 = optional(string)
      interface_index      = optional(number)
      interface_name       = optional(string)
      description          = optional(string)
      ike_version          = optional(number)
      ike_psk              = optional(string)
      cloud_router_ip      = optional(string)
      bgp_name             = optional(string)
      bgp_peer_ip          = optional(string)
      peer_bgp_asn         = optional(number)
      advertised_priority  = optional(number)
      advertised_groups    = optional(list(string))
      advertised_ip_ranges = optional(list(string))
      enable_bfd           = optional(bool)
      enable               = optional(bool)
    }))
  }))
  default = {}
}
