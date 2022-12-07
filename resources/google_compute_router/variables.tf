variable "project_id" {
  description = "Project ID of our VPC network"
  type        = string
  default     = null
}
variable "name" {
  type        = string
  description = "Cloud Router Name.  Default will be {vpc_network_name}-{region}"
  default     = null
}
variable "description" {
  type        = string
  description = "Cloud Router Description"
  default     = null
}
variable "vpc_network_name" {
  type        = string
  description = "Name of VPC Network"
}
variable "region" {
  type        = string
  description = "GCP region name"
}
variable "bgp_asn" {
  description = "BGP ASN Number"
  type        = number
  default     = 64512
}
variable "bgp_advertise_mode" {
  description = "Mode to advertise routes: can be DEFAULT or CUSTOM"
  type        = string
  default     = "DEFAULT"
}
variable "bgp_advertised_groups" {
  description = "Groups to advertise (i.e. [\"ALL_SUBNETS\"])"
  type        = list(string)
  default     = []
}
variable "bgp_advertised_ip_ranges" {
  description = "List of routes to advertise (if using CUSTOM mode)"
  type = list(object({
    range       = string
    description = optional(string)
  }))
  default = []
}
variable "bgp_keepalive_interval" {
  description = "Seconds between BGP keepalive messages"
  type        = number
  default     = 20
}
