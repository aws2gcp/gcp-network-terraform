variable "name_prefix" {
  description = "Name Prefix to give to all resources"
  type        = string
  default     = "vpc"
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "network_name" {
  type        = string
  description = "Name of VPC Network"
  default     = null
}
variable "region" {
  description = "GCP Region Name"
  type        = string
}
variable "cloud_router_bgp_asn" {
  type    = string
  default = 64512
}
variable "cloud_nat_num_static_ips" {
  type    = number
  default = 1
}
variable "cloud_nat_min_ports_per_vm" {
  type    = number
  default = 128
}
variable "cloud_nat_max_ports_per_vm" {
  type    = number
  default = 4096
}
variable "cloud_nat_log_type" {
  type    = string
  default = "errors"
}
variable "main_cidrs" {
  type = list(string)
}
variable "gke_pods_cidrs" {
  type    = list(string)
  default = []
}
variable "gke_services_cidrs" {
  type    = list(string)
  default = []
}
variable "gke_services_range_length" {
  type    = number
  default = 22
}
variable "create_proxy_only_subnet" {
  type    = bool
  default = true
}
variable "proxy_only_cidr" {
  type    = string
  default = null
}
variable "proxy_only_purpose" {
  type    = string
  default = "REGIONAL_MANAGED_PROXY"
}
variable "psc_prefix_base" {
  type    = string
  default = null
}
variable "psc_subnet_length" {
  type    = number
  default = 28
}
variable "num_psc_subnets" {
  type    = number
  default = 16
}
variable "psc_purpose" {
  type    = string
  default = "PRIVATE_SERVICE_CONNECT"
}
variable "servicenetworking_cidr" {
  type = string
}
variable "netapp_cidr" {
  type = string
}
variable "cloud_nat_routes" {
  type    = list(string)
  default = []
}
variable "shared_accounts" {
  type    = list(string)
  default = []
}
variable "subnet_shared_accounts" {
  type    = list(string)
  default = []
}
variable "attached_projects" {
  type    = list(string)
  default = []
}
variable "subnet_attached_projects" {
  type    = list(string)
  default = []
}
variable "routes" {
  type = list(object({
    name        = optional(string)
    description = optional(string)
    priority    = optional(number)
    dest_ranges = optional(list(string))
  }))
  default = []
}
variable "hub_vpc" {
  type = object({
    project_id           = optional(string)
    network_name         = optional(string, "default")
    bgp_asn              = optional(number, 64512)
    advertised_ip_ranges = optional(list(string), ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"])
  })
}