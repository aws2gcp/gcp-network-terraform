variable "project_id" {
  description = "GCP Project ID of GCP"
  type        = string
}
variable "name_prefix" {
  description = "Name prefix for the instances and load balancer"
  type        = string
}
variable "machine_type" {
  description = "Machine Type"
  type        = string
  default     = "g1-small"
}
variable "disk_type" {
  description = "Disk Type"
  type        = string
  default     = "pd-standard"
}
variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 12
}
variable "image" {
  description = "GCP OS Image"
  type        = string
  default     = "debian-cloud/debian-11"
}
variable "os_project" {
  type    = string
  default = "debian-cloud"
}
variable "os" {
  type    = string
  default = "debian-11"
}
variable "startup_script" {
  description = "Startup Script"
  type        = string
  default     = null
}
variable "service_account_email" {
  description = "Service Account e-mail address"
  type        = string
  default     = null
}
variable "service_account_scopes" {
  description = "List of Service Account Scopes"
  type        = list(string)
  default     = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
}
variable "network_tags" {
  description = "List of Network Tags"
  type        = list(string)
  default     = null
}
variable "ports" {
  description = "List of ports to forward on the frontend of the load balancer"
  type        = list(string)
  default     = []
}
variable "network_project_id" {
  description = "If using Shared VPC, the Project ID that hosts the VPC network"
  type        = string
  default     = null
}
variable "network_name" {
  description = "Name of the VPC Network"
  type        = string
  default     = null
}
variable "affinity_type" {
  description = "Session affinity type for backend"
  type        = string
  default     = "NONE"
}
variable "global_access" {
  description = "Allow access to LB from outside of local region (ILB only)"
  type        = bool
  default     = false
}
variable "healthcheck_interval" {
  type    = number
  default = 10
}
variable "target_size" {
  type    = number
  default = null
}
variable "autoscaling_mode" {
  type    = string
  default = "OFF"
}
variable "cool_down_period" {
  type    = number
  default = 60
}
variable "cpu_target" {
  type    = number
  default = null
}
variable "cpu_predictive_method" {
  type    = string
  default = null
}
variable "min_replicas" {
  type    = number
  default = null
}
variable "max_replicas" {
  type    = number
  default = null
}
variable "labels" {
  type    = map(any)
  default = null
}
variable "update_type" {
  type    = string
  default = null
}
variable "deployments" {
  description = "Regions to deploy instances and/or iLB to"
  type = map(object({
    enabled               = optional(bool)
    create_ilb            = optional(bool)
    region                = optional(string)
    subnet_name           = optional(string)
    ip_address            = optional(string)
    ip_address_name       = optional(string)
    ports                 = optional(list(number))
    forwarding_rule_name  = optional(string)
    target_size           = optional(number)
    min_replicas          = optional(number)
    max_replicas          = optional(number)
    global_access         = optional(bool)
    cpu_target            = optional(number)
    cpu_predictive_method = optional(string)
    instance_groups = optional(list(object({
      id        = optional(string)
      name      = optional(string)
      zone      = optional(string)
      instances = optional(list(string))
    })))
    psc = optional(object({
      service_name                = optional(string)
      nat_subnet_ids              = optional(list(string))
      nat_subnet_names            = optional(list(string))
      auto_accept_all_connections = optional(bool)
      accept_project_ids          = optional(list(string))
    }))
  }))
  default = {}
}
