variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden)"
  default     = null
}
variable "dns_zones" {
  description = "DNS zones"
  type = list(object({
    project_id        = optional(string)
    dns_name          = string
    name              = optional(string)
    description       = optional(string)
    visibility        = optional(string)
    visible_networks  = optional(list(string))
    peer_project_id   = optional(string)
    peer_network_name = optional(string)
    logging           = optional(bool)
    force_destroy     = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = optional(string)
      forwarding_path = optional(string)
    })))
    records = optional(list(object({
      name    = string
      type    = optional(string)
      ttl     = optional(number)
      rrdatas = list(string)
    })))
    create = optional(bool)
  }))
  default = []
}
variable "dns_policies" {
  description = "DNS Policies"
  type = list(object({
    project_id                = optional(string)
    name                      = optional(string)
    description               = optional(string)
    logging                   = optional(bool)
    enable_inbound_forwarding = optional(bool)
    target_name_servers = optional(list(object({
      ipv4_address    = optional(string)
      forwarding_path = optional(string)
    })))
    networks = optional(list(string))
    create   = optional(bool)
  }))
  default = []
}