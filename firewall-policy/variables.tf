variable "project_id" {
  type        = string
  description = "Default GCP Project ID (can be overridden)"
  default     = null
}
variable "network_firewall_policies" {
  description = "Map of Network Firewall Policies"
  type = map(object({
    project_id   = optional(string)
    name         = optional(string)
    description  = optional(string)
    associations = optional(list(string))
    rules = list(object({
      description    = optional(string)
      priority       = optional(number)
      direction      = optional(string)
      action         = optional(bool)
      enable_logging = optional(bool)
      src_ip_ranges  = optional(list(string))
      dest_ip_ranges = optional(list(string))
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })))
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })))
    }))
  }))
  default = {}
  #default = { default = { rules = [] } }
}
