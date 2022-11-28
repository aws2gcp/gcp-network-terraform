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
  description = "Parameters of this Healthcheck"
  type = object({
    port         = optional(number, 80)
    protocol     = optional(string, "HTTP")
    interval     = optional(number, 10)
    timeout      = optional(number, 5)
    request_path = optional(string, "/")
    response     = optional(string, "OK")
    regional     = optional(string, false)
    legacy       = optional(bool, false)
  })
  default = {}
}
