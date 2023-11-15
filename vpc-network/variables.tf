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
variable "region" {
  description = "Default region for all resources (can be overriden)"
  type        = string
  default     = null
}
variable "attached_projects" {
  description = "For Shared VPC, list of service projects to share this network to"
  type        = list(string)
  default     = null
}
variable "shared_accounts" {
  description = "For Shared VPC, list of members to share this network to"
  type        = list(string)
  default     = null
}
variable "subnets" {
  description = "Subnets in this VPC Network"
  type = list(object({
    create                   = optional(bool)
    project_id               = optional(string)
    name                     = optional(string)
    description              = optional(string)
    region                   = optional(string)
    stack_type               = optional(string)
    ip_range                 = string
    purpose                  = optional(string)
    role                     = optional(string)
    private_access           = optional(bool)
    flow_logs                = optional(bool)
    log_aggregation_interval = optional(string)
    log_sampling_rate        = optional(number)
    attached_projects        = optional(list(string))
    shared_accounts          = optional(list(string))
    secondary_ranges = optional(list(object({
      name  = optional(string)
      range = string
    })))
    create = optional(bool)
  }))
  default = []
}
variable "routes" {
  description = "Static Routes"
  type = list(object({
    project_id    = optional(string)
    name          = optional(string)
    description   = optional(string)
    dest_range    = optional(string)
    dest_ranges   = optional(list(string))
    priority      = optional(number)
    instance_tags = optional(list(string))
    next_hop      = optional(string)
    next_hop_zone = optional(string)
    create        = optional(bool)
  }))
  default = []
}
variable "peerings" {
  description = "VPC Peering Connections"
  type = list(object({
    project_id                          = optional(string)
    name                                = optional(string)
    peer_project_id                     = optional(string)
    peer_network_name                   = optional(string)
    peer_network_link                   = optional(string)
    import_custom_routes                = optional(bool)
    export_custom_routes                = optional(bool)
    import_subnet_routes_with_public_ip = optional(bool)
    export_subnet_routes_with_public_ip = optional(bool)
    create                              = optional(bool)
  }))
  default = []
}
variable "cloud_routers" {
  description = "Cloud Routers attached to this VPC Network"
  type = list(object({
    project_id             = optional(string)
    name                   = optional(string)
    description            = optional(string)
    region                 = optional(string)
    bgp_asn                = optional(number)
    bgp_keepalive_interval = optional(number)
    advertised_groups      = optional(list(string))
    advertised_ip_ranges = optional(list(object({
      create      = optional(bool)
      range       = string
      description = optional(string)
    })))
    create = optional(bool)
  }))
  default = []
}
variable "cloud_nats" {
  description = "Cloud NATs used by this VPC Network"
  type = list(object({
    project_id        = optional(string)
    name              = optional(string)
    region            = optional(string)
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
    tcp_time_wait_timeout        = optional(number)
    tcp_transitory_idle_timeout  = optional(number)
    icmp_idle_timeout            = optional(number)
    create                       = optional(bool)
  }))
  default = []
}
/*
variable "firewall_rules" {
  description = "Firewall Rules applied to this VPC Network"
  type = map(object({
    project_id       = optional(string)
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
    create           = optional(bool)
  }))
  default = {}
}
*/
variable "ip_ranges" {
  description = "Internal IP address ranges for private service connections"
  type = list(object({
    project_id  = optional(string)
    name        = optional(string)
    description = optional(string)
    ip_range    = string
    create      = optional(bool)
  }))
  default = []
}
variable "service_connections" {
  description = "Private Service Connections"
  type = list(object({
    project_id           = optional(string)
    name                 = optional(string)
    service              = optional(string)
    ip_ranges            = list(string)
    import_custom_routes = optional(bool)
    export_custom_routes = optional(bool)
    create               = optional(bool)
  }))
  default = []
}
variable "private_service_connections" {
  description = "Private Service Connections"
  type = list(object({
    name       = optional(string)
    target     = string
    ip_address = optional(string)
    create     = optional(bool)
  }))
  default = []
}
variable "private_service_connects" {
  description = "Private Service Connects"
  type = list(object({
    name          = optional(string)
    target        = string
    endpoint_name = optional(string)
    subnet_name   = optional(string)
    region        = optional(string)
    ip_address    = optional(string)
    create        = optional(bool)
  }))
  default = []
}
variable "vpc_access_connectors" {
  description = "Serverless VPC Access Connectors"
  type = list(object({
    project_id         = optional(string)
    name               = optional(string)
    region             = optional(string)
    cidr_range         = optional(string)
    subnet_name        = optional(string)
    vpc_network_name   = optional(string)
    network_project_id = optional(string)
    min_throughput     = optional(number)
    max_throughput     = optional(number)
    min_instances      = optional(number)
    max_instances      = optional(number)
    machine_type       = optional(string)
    create             = optional(bool)
  }))
  default = []
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
    cloud_nat_tcp_time_wait_timeout        = optional(number, 120)
    cloud_nat_tcp_transitory_idle_timeout  = optional(number, 30)
    cloud_nat_icmp_idle_timeout            = optional(number, 30)
    cloud_nat_min_ports_per_vm             = optional(number, 64)
    cloud_nat_max_ports_per_vm             = optional(number, 4096)
    cloud_nat_log_type                     = optional(string, "errors")
  })
  default = {}
}
