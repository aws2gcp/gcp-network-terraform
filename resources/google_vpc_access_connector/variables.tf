variable "project_id" {
  type    = string
  default = null
}
variable "name" {
  description = "Name of the connection"
  type        = string
  default     = null
}
variable "vpc_network_name" {
  description = "Name of the VPC Network"
  type        = string
}
variable "cidr_range" {
  description = "IP CIDR range for this connection"
  type        = string
  default     = null
}
variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = null
}
variable "region" {
  description = "GCP Region Name"
  type        = string
}
variable "network_project_id" {
  description = "Host project ID (for shared VPC only)"
  type        = string
  default     = null
}
variable "min_instances" {
  type    = number
  default = 2
}
variable "max_instances" {
  type    = number
  default = 10
}
variable "machine_type" {
  type    = string
  default = "e2-micro"
}
