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
  description = "Parameters for this SSL Certificate & Key"
  type = object({
    domains                 = optional(list(string))
    certificate             = optional(string)
    private_key             = optional(string)
    regional                = optional(bool, false)
    region                  = optional(string)
    self_signed             = optional(bool)
    self_signed_valid_hours = optional(number)
    self_signed_valid_days  = optional(number)
    self_signed_valid_years = optional(number, 10)
  })
  default = {}
}