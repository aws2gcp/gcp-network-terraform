variable "project_id" {
  description = "GCP Project ID to create resources in"
  type        = string
  default     = null
}
variable "network_project_id" {
  description = "If using Shared VPC, the GCP Project ID for the host network"
  type        = string
  default     = null
}
variable "create" {
  description = "Whether or not to build forwarding rule"
  type        = bool
  default     = true
}
variable "region" {
  description = "GCP region name for the IP address and forwarding rule"
  type        = string
  default     = null
}
variable "name" {
  description = "Name for the PSC Endpoint and IP Address"
  type        = string
  default     = null
}
variable "description" {
  description = "Description for the IP Address for the PSC Endpoint"
  type        = string
  default     = null
}
variable "network_name" {
  description = "Local VPC Network Name"
  type        = string
  default     = "default"
}
variable "subnet_id" {
  description = "Subnetwork ID (projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET_NAME)"
  type        = string
  default     = null
  validation {
    condition     = var.subnet_id != null ? startswith(var.subnet_id, "projects/") : true
    error_message = "Subnetwork ID should start with 'projects/'."
  }
}
variable "subnet_name" {
  description = "Subnetwork Name"
  type        = string
  default     = "default"
}
variable "target_id" {
  description = "ID of the published service (projects/PUBLISHER_PROJECT_ID/regions/REGION/serviceAttachments/SERVICE_NAME)"
  type        = string
  default     = null
  validation {
    condition     = var.target_id != null ? startswith(var.target_id, "projects/") : true
    error_message = "Target Service ID should start with 'projects/'."
  }
}
variable "target_project_id" {
  description = "Project ID of the published service"
  type        = string
  default     = null
}
variable "target_region" {
  description = "Region of the published service"
  type        = string
  default     = null
}
variable "target_name" {
  description = "Name of the published service"
  type        = string
  default     = null
}
variable "global_access" {
  description = "Allow access to forwarding rule from all regions"
  type        = bool
  default     = null
}
