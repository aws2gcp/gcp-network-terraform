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
  description = "Parameters for this Serverless Application"
  type = object({
    region                 = optional(string, "us-central1")
    runtime                = optional(string, "nodejs16")
    available_memory       = optional(number, 128)
    trigger_http           = optional(bool, true)
    entry_point            = optional(string, "function")
    min_instances          = optional(number, 0)
    max_instances          = optional(number, 2)
    timeout                = optional(number, 60)
    environment_variables  = optional(map, {})
    image                  = optional(string)
    container_ports        = optional(list(number), [8080])
    vpc_connector          = optional(string)
    cloud_function_version = optional(number, 1)
  })
  validation {
    condition     = var.params.available_memory >= 16 && var.params.available_memory <= 4096
    error_message = "Memory size must be between 16 MB and 4 GB"
  }
  default = {}
}
