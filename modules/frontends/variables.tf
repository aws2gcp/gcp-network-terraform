variable "project_id" {
  description = "Project ID for these Beautiful Resources"
  type        = string
}
variable "name" {
  description = "Name of this Thang"
  type        = string
  default     = null
}
variable "description" {
  description = "Tell me more, Tell me more"
  type        = string
  default     = null
}
variable "create" {
  description = "Do or don't do, there is no try"
  type        = bool
  default     = true
}
variable "params" {
  description = "Parameters for this frontend"
  type = object({
    classic                = optional(bool, false)
    type                   = optional(string, "external")
    protocol               = optional(string, "tcp")
    vpc_network_name       = optional(string)
    network_project_id     = optional(string)
    subnet_name            = optional(string)
    ip_address             = optional(string)
    psc_nat_subnets        = optional(list(string))
    port                   = optional(number, 80)
    ports                  = optional(list(string), [])
    all_ports              = optional(bool, false)
    allow_global_access    = optional(bool, false)
    http_port              = optional(number, 80)
    https_port             = optional(number, 443)
    enable_http            = optional(bool, false)
    enable_https           = optional(bool, false)
    redirect_to_https      = optional(bool, false)
    redirect_response_code = optional(number)
    strip_query_on_redirect = optional(bool, true)
    region                 = optional(string)
    target_id              = optional(string)
    use_target_pools       = optional(bool, false)
    default_backend = optional(string)
    route_rules = optional(list(object({
      hostnames = list(string)
      backend   = optional(string)
      path_rules = optional(list(object({
        paths   = list(string)
        backend = string
      })))
    })))
    ssl_certs = optional(list(string))
    ssl_certificates = optional(map(object({
      description = optional(string)
      domains     = optional(list(string))
      certificate = optional(string)
      private_key = optional(string)
    })))
    psc_name                     = optional(string)
    psc_auto_accept_all_projects = optional(bool, false)
    psc_accept_project_ids       = optional(list(string), [])
    psc_enable_proxy_protocol    = optional(bool, false)
  })
  default = {}
}
