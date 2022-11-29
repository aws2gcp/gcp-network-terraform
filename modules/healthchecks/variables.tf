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
  description = "Parameters of this Healthcheck"
  type = object({
    port                = optional(number, 80)
    protocol            = optional(string, "TCP")
    interval            = optional(number, 10)
    timeout             = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
    request_path        = optional(string, "/")
    response            = optional(string, "OK")
    regional            = optional(string, false)
    region              = optional(string)
    legacy              = optional(bool, false)
    logging             = optional(bool, false)
  })
  default = {}
}
