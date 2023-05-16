variable "project_id" {
  type = string
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "name_prefix" {
  type = string
}
variable "description" {
  type    = string
  default = null
}
variable "instance_template_name" {
  type    = string
  default = null
}
variable "base_instance_name" {
  type    = string
  default = null
}
variable "network_name" {
  type    = string
  default = "default"
}
variable "subnet_name" {
  type    = string
  default = "default"
}
variable "region" {
  type = string
}
variable "zones" {
  type    = list(string)
  default = null
}
variable "target_size" {
  type    = number
  default = null
}
variable "machine_type" {
  type    = string
  default = "e2-small"
}
variable "image" {
  type    = string
  default = null
}
variable "os_project" {
  type    = string
  default = null
}
variable "os" {
  type    = string
  default = null
}
variable "network_tags" {
  type    = list(string)
  default = null
}
variable "labels" {
  type    = map(any)
  default = {}
}
variable "service_account_email" {
  type    = string
  default = null
}
variable "service_account_scopes" {
  type    = list(string)
  default = null
}
variable "ssh_key" {
  type    = string
  default = null
}
variable "enable_ip_forwarding" {
  type    = bool
  default = false
}
variable "startup_script" {
  type    = string
  default = null
}
variable "disk_type" {
  type    = string
  default = null
}
variable "disk_size" {
  type    = number
  default = null
}
variable "disk_auto_delete" {
  type    = bool
  default = true
}
variable "disk_boot" {
  type    = bool
  default = true
}
variable "healthcheck_ids" {
  type    = list(string)
  default = null
}
variable "healthcheck_name" {
  type    = list(string)
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
variable "cool_down_period" {
  type    = number
  default = null
}
variable "cpu_target" {
  type    = number
  default = null
}
variable "cpu_predictive_method" {
  type    = string
  default = null
}
variable "autoscaling_mode" {
  type    = string
  default = null
}
variable "auto_healing_initial_delay" {
  type    = number
  default = null
}
variable "update_type" {
  type    = string
  default = null
}
variable "update_minimal_action" {
  type    = string
  default = null
}
variable "update_most_disruptive_action" {
  type    = string
  default = null
}
variable "update_replacement_method" {
  type    = string
  default = null
}
variable "metadata" {
  type    = map(string)
  default = null
}
variable "create" {
  type    = bool
  default = true
}