variable "project_id" {
  type    = string
  default = null
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "vpc_network_name" {
  type    = string
  default = "default"
}
variable "subnet_name" {
  type    = string
  default = "default"
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "machine_type" {
  type    = string
  default = "f1-micro"
}
variable "boot_disk_type" {
  type    = string
  default = null
}
variable "boot_disk_size" {
  type    = number
  default = null
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
variable "startup_script" {
  type    = string
  default = "echo 'Created with terraform' > /tmp/terraform.txt"
}
variable "network_tags" {
  type    = list(string)
  default = null
}
variable "service_account_email" {
  type    = string
  default = null
}
variable "service_account_scopes" {
  type    = list(string)
  default = ["compute-rw", "storage-rw", "logging-write", "monitoring"]
}
variable "ssh_key" {
  type    = string
  default = null
}
variable "enable_ip_forwarding" {
  type    = bool
  default = false
}
variable "metadata_startup_script" {
  type    = string
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
