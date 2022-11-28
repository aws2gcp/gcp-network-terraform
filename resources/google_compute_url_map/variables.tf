variable "name" {
  description = "Name for this URL Map"
  type        = string
  default     = null
}
variable "default_backend" {
  description = "ID of the default service or bucket"
  type        = string
  default     = null
}
variable "redirect_to_https" {
  description = "Redirect all requests to HTTPS"
  type        = bool
  default     = false
}
variable "strip_query_on_redirect" {
  description = "Ignore Query Parameters when doing Redirect"
  type        = bool
  default     = false
}
variable "backend_prefix" {
  description = "Naming prefix for the backend"
  type        = string
  default     = "backend"
}
variable "route_rules" {
  description = "Hostname and Path to Backend Matching"
  type = list(object({
    hostnames = list(string)
    backend   = optional(string)
    path_rules = optional(list(object({
      paths   = list(string)
      backend = string
    })))
  }))
  default = []
}
