variable "project_id" {
  type        = string
  description = "Project ID of GCP Project"
}
variable "network_name" {
  type        = string
  description = "Name of VPC Network"
}
variable "description" {
  type        = string
  description = "Description of VPC Network"
  default     = null
}
variable "mtu" {
  description = "MTU for the VPC network: 1460 (default) or 1500"
  type        = number
  default     = null
}
variable "enable_global_routing" {
  description = "Enable Global Routing (default is Regional)"
  type        = bool
  default     = null
}
variable "auto_create_subnetworks" {
  type    = bool
  default = null
}
variable "service_project_ids" {
  description = "For Shared VPC, list of service projects to share this network to"
  type        = list(string)
  default     = null
}
variable "subnets" {
  description = "Subnets in this VPC Network"
  type = map(object({
    name                     = optional(string)
    description              = optional(string)
    region                   = string
    stack_type               = optional(string)
    ip_range                 = string
    purpose                  = optional(string)
    role                     = optional(string)
    private_access           = optional(bool)
    flow_logs                = optional(bool)
    log_aggregation_interval = optional(string)
    log_sampling_rate        = optional(number)
    attached_projects        = optional(list(string))
    secondary_ranges = optional(map(object({
      range = string
    })))
  }))
  default = {}
}
variable "routes" {
  description = "Static Routes"
  type = map(object({
    name          = optional(string)
    description   = optional(string)
    dest_range    = optional(string)
    dest_ranges   = optional(list(string))
    priority      = optional(number)
    instance_tags = optional(list(string))
    next_hop      = optional(string)
    next_hop_zone = optional(string)
  }))
  default = {}
}

variable "peerings" {
  description = "VPC Peering Connections"
  type = map(object({
    name                                = optional(string)
    peer_project_id                     = optional(string)
    peer_network_name                   = string
    import_custom_routes                = optional(bool)
    export_custom_routes                = optional(bool)
    import_subnet_routes_with_public_ip = optional(bool)
    export_subnet_routes_with_public_ip = optional(bool)
  }))
  default = {}
}
variable "cloud_routers" {
  description = "Cloud Routers attached to this VPC Network"
  type = map(object({
    name                   = optional(string)
    description            = optional(string)
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
variable "cloud_nats" {
  description = "Cloud NATs used by this VPC Network"
  type = map(object({
    name              = optional(string)
    region            = string
    cloud_router      = optional(string)
    cloud_router_name = optional(string)
    subnets           = optional(list(string))
    num_static_ips    = optional(number)
    static_ips = optional(list(object({
      name        = optional(string)
      description = optional(string)
      address     = optional(string)
    })))
    log_type                     = optional(string)
    enable_dpa                   = optional(bool)
    min_ports_per_vm             = optional(number)
    max_ports_per_vm             = optional(number)
    enable_eim                   = optional(bool)
    udp_idle_timeout             = optional(number)
    tcp_established_idle_timeout = optional(number)
    tcp_transitory_idle_timeout  = optional(number)
    icmp_idle_timeout            = optional(number)
  }))
  default = {}
}
variable "firewall_rules" {
  description = "Firewall Rules applied to this VPC Network"
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    priority         = optional(number)
    direction        = optional(string)
    logging          = optional(bool)
    ranges           = optional(list(string))
    source_tags      = optional(list(string))
    target_tags      = optional(list(string))
    service_accounts = optional(list(string))
    action           = optional(bool)
  }))
  default = {}
}
variable "ip_ranges" {
  description = "Internal IP address ranges for private service connections"
  type = map(object({
    name        = optional(string)
    description = optional(string)
    ip_range    = string
  }))
  default = {}
}
variable "service_connections" {
  description = "Private Service Connections"
  type = map(object({
    name      = optional(string)
    service   = optional(string)
    ip_ranges = list(string)
  }))
  default = {}
}
variable "private_service_connections" {
  description = "Private Service Connections"
  type = map(object({
    target     = string
    ip_address = optional(string)
  }))
  default = {}
}
variable "private_service_connects" {
  description = "Private Service Connects"
  type = map(object({
    target        = string
    endpoint_name = optional(string)
    subnet_name   = optional(string)
    region        = optional(string)
    ip_address    = optional(string)
  }))
  default = {}
}
variable "vpc_access_connectors" {
  description = "Serverless VPC Access Connectors"
  type = map(object({
    name               = optional(string)
    region             = string
    cidr_range         = optional(string)
    subnet_name        = optional(string)
    vpc_network_name   = optional(string)
    network_project_id = optional(string)
    min_throughput     = optional(number)
    max_throughput     = optional(number)
    min_instances      = optional(number)
    max_instances      = optional(number)
    machine_type       = optional(string)
  }))
  default = {}
}
variable "defaults" {
  type = object({
    cloud_router_bgp_asn                   = optional(number, 64512)
    cloud_router_bgp_keepalive_interval    = optional(number, 20)
    subnet_stack_type                      = optional(string, "IPV4_ONLY")
    subnet_private_access                  = optional(bool, false)
    subnet_flow_logs                       = optional(bool, false)
    subnet_log_aggregation_interval        = optional(string, "INTERVAL_5_SEC")
    subnet_log_sampling_rate               = optional(string, "0.5")
    cloud_nat_enable_dpa                   = optional(bool, true)
    cloud_nat_enable_eim                   = optional(bool, false)
    cloud_nat_udp_idle_timeout             = optional(number, 30)
    cloud_nat_tcp_established_idle_timeout = optional(number, 1200)
    cloud_nat_tcp_transitory_idle_timeout  = optional(number, 30)
    cloud_nat_icmp_idle_timeout            = optional(number, 30)
  })
  default = {}
}