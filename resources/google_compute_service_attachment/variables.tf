variable "project_id" {
  type = string
}
variable "name" {
  description = "Name for the Published Service"
  type        = string
}
variable "description" {
  description = "Description for the Published Service"
  type        = string
  default     = null
}
variable "region" {
  description = "GCP region name"
  type        = string
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "nat_subnet_names" {
  description = "NAT subnets for this region"
  type        = list(string)
}
variable "target_service_id" {
  description = "Load Balancer Service ID to publish "
  type        = string
}
variable "enable_proxy_protocol" {
  description = "enable the proxy protocol"
  type        = bool
  default     = false
}
variable "auto_accept_all_projects" {
  description = "Set whether to auto-accept connections from any project"
  type        = bool
  default     = false
}
variable "accept_project_ids" {
  description = "List of Project IDs to accept connections from"
  type        = list(string)
  default     = null
}
