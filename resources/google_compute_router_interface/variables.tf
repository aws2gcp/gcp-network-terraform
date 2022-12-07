variable "project_id" {
  description = "Project ID for this resource"
  type        = string
  default     = null
}
variable "name_prefix" {
  description = "Naming Prefix for interfaces (default is use cloud router name)"
  type        = string
  default     = null
}
variable "type" {
  description = "Type of interface (vpn or interconnect)"
  type        = string
  default     = "vpn"
}
variable "region" {
  type        = string
  description = "GCP region name for this cloud router"
}
variable "cloud_router_name" {
  type        = string
  description = "Cloud Router name"
}
variable "peer_vpn_gateway_name" {
  type        = string
  description = "Name of the Peer (External) VPN Gateway"
  default     = null
}
variable "interfaces" {
  type = list(object({
    interface_id    = optional(number)
    interface_name  = optional(string)
    vpn_name        = optional(string)
    attachment_name = optional(string)
    cloud_router_ip = string
  }))
  default     = []
  description = "Parameters for each Cloud Router Interface"
}
variable "interconnect_attachments" {
  description = "List of Interconnect Attachment names"
  type        = list(string)
  default     = []
}
