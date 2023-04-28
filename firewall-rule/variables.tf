variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "name" {
  description = "Name for this Firewall Rule"
  type        = string
  default     = null
  validation {
    condition     = var.name != null ? length(var.name) < 64 : true
    error_message = "Name cannot exceed 63 characters."
  }
}
variable "name_prefix" {
  description = "Name Prefix for this rule.  Rest of name will be auto-generated"
  type        = string
  default     = null
  validation {
    condition     = var.name_prefix != null ? length(var.name_prefix) <= 50 : true
    error_message = "Name prefix cannot exceed 50 characters."
  }
}
variable "short_name" {
  description = "Short name for this rule.  Rule name will be var.name_prefix + var.short_name"
  type        = string
  default     = null
  validation {
    condition     = var.short_name != null ? length(var.short_name) <= 32 : true
    error_message = "Short name cannot exceed 32 characters."
  }
}
variable "description" {
  type    = string
  default = "Created by Terraform"
}
variable "network_name" {
  description = "Name of the VPC network rule applies to"
  type        = string
  default     = null
}
variable "network" {
  description = "Name of the VPC network rule applies to"
  type        = string
  default     = null
}
variable "priority" {
  description = "Priority Number (lower number is higher priority)"
  type        = number
  default     = null
  validation {
    condition     = var.priority != null ? var.priority >= 0 && var.priority <= 65535 : true
    error_message = "Priority number must be between zero and 65535."
  }
}
variable "logging" {
  description = "Log hits to this rule"
  type        = bool
  default     = false
}
variable "direction" {
  description = "Direction (ingress or egress)"
  type        = string
  default     = null
  validation {
    condition     = var.direction != null ? upper(var.direction) == "INGRESS" || upper(var.direction) == "EGRESS" : true
    error_message = "Direction must be ingress or egress."
  }
}
variable "ranges" {
  description = "IP Ranges for this Rule"
  type        = list(string)
  default     = null
}
variable "range" {
  description = "IP Range for this Rule"
  type        = string
  default     = null
}
variable "range_types" {
  type    = list(string)
  default = null
}
variable "range_type" {
  type    = string
  default = null
}
variable "protocol" {
  description = "Network Protocol (tcp, udp, icmp, esp, gre, etc)"
  type        = string
  default     = null
}
variable "protocols" {
  description = "Network Protocols (plural).  Example: [\"tcp\", \"udp\"]"
  type        = list(string)
  default     = null
}
variable "port" {
  description = "TCP or UDP Port to allow or deny"
  type        = number
  default     = null
}
variable "ports" {
  description = "TCP Ports to allow or deny"
  type        = list(string)
  default     = null
  validation {
    condition     = var.ports != null ? length(var.ports) > 0 : true
    error_message = "If specified, ports list should contain at least one valid port."
  }

}
variable "source_tags" {
  description = "Source Network Tags to match (ingress only)"
  type        = list(string)
  default     = null
}
variable "source_service_accounts" {
  description = "Source Service Accounts to match (ingress only)"
  type        = list(string)
  default     = null
}
variable "target_tags" {
  description = "Network Tags to apply this rule to"
  type        = list(string)
  default     = null
}
variable "target_service_accounts" {
  description = "Service Accounts to apply this rule to"
  type        = list(string)
  default     = null
}
variable "action" {
  description = "Action (should be allow or deny)"
  type        = string
  default     = null
  validation {
    condition     = var.action != null ? upper(var.action) == "ALLOW" || upper(var.action) == "DENY" : true
    error_message = "Action must be allow or deny."
  }
}
variable "allow" {
  description = "List of protocols and ports (if applicable) to allow"
  type = list(object({
    protocol = string
    ports    = list(string)
  }))
  default = null
}
variable "deny" {
  description = "List of protocols and ports (if applicable) to deny"
  type = list(object({
    protocol = string
    ports    = list(string)
  }))
  default = null
}
variable "enforcement" {
  description = "Whether to actually enforce this rule"
  type        = bool
  default     = true
}
variable "disabled" {
  description = "Whether to actually enforce this rule"
  type        = bool
  default     = false
}

