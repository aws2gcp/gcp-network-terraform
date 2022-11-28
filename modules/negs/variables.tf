variable "project_id" {
  description = "Project ID for these Beautiful Resources"
  type        = string
}
variable "region" {
  description = "Name of the GCP Region for these Wonderful Resources"
  type        = string
  default     = null
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
  type = object({
    ip_address            = optional(string)
    fqdn                  = optional(string)
    port                  = optional(number, 443) # Only used by inegs
    cloud_function_name   = optional(string)
    cloud_run_name        = optional(string)
    app_engine_service    = optional(string)
    app_engine_version_id = optional(string)
  })
  default = {}
}
