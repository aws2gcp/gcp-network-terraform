variable "project_id" {
  type = string
}
variable "name" {
  type    = string
  default = null
  validation {
    condition     = var.name != null ? length(var.name) < 64 : true
    error_message = "Name cannot exceed 63 characters."
  }
}
variable "description" {
  type    = string
  default = null
}
variable "port" {
  type    = number
  default = 80
  validation {
    condition     = var.port >= 0 && var.port < 65536
    error_message = "Port must be between 0 and 65535."
  }
}
variable "protocol" {
  type    = string
  default = null
  validation {
    condition     = var.protocol != null ? upper(var.protocol) == "TCP" || upper(var.protocol) == "HTTP" || upper(var.protocol) == "HTTPS" : true
    error_message = "Protocol must be TCP, HTTP, or HTTPS."
  }
}
variable "region" {
  type    = string
  default = null
}
variable "interval" {
  type    = number
  default = 5
  validation {
    condition     = var.interval > 0 && var.interval <= 300
    error_message = "Interval must be between 1 second and 5 minutes."
  }
}
variable "timeout" {
  type    = number
  default = 4
  validation {
    condition     = var.timeout > 0 && var.timeout <= 120
    error_message = "Timeout must be between 1 second and 2 minutes."
  }
}
variable "healthy_threshold" {
  type    = number
  default = 2
  validation {
    condition     = var.healthy_threshold > 0 && var.healthy_threshold <= 5
    error_message = "Healthy threshold must be between 1 and 5."
  }
}
variable "unhealthy_threshold" {
  type    = number
  default = 2
  validation {
    condition     = var.unhealthy_threshold > 0 && var.unhealthy_threshold <= 5
    error_message = "Unhealthy threshold must be between 1 and 5."
  }
}
variable "request_path" {
  type    = string
  default = null
}
variable "response" {
  type    = string
  default = null
}
variable "host" {
  type    = string
  default = null
}
variable "legacy" {
  type    = bool
  default = false
}
variable "logging" {
  type    = bool
  default = false
}
variable "proxy_header" {
  type    = string
  default = null
}
variable "create" {
  type    = bool
  default = true
}