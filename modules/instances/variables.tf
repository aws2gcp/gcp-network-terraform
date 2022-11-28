variable "project_id" {
  description = "Project ID for these Beautiful Resources"
  type        = string
  default     = null
}
variable "region" {
  description = "Name of the GCP Region for these Wonderful Resources"
  type        = string
  default     = null
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
  description = "Parameters for this Compute Instance"
  type = object({
    zone                   = optional(string)
    zones                  = optional(list(string))
    auto_scale             = optional(bool, false)
    num_instances          = optional(string, 1)
    network_id             = optional(string)
    vpc_network_name       = optional(string)
    network_project_id     = optional(string)
    subnet_name            = optional(string)
    machine_type           = optional(string, "f1-micro")
    boot_disk_type         = optional(string, "pd-standard")
    boot_disk_size         = optional(number, 10)
    image                  = optional(string)
    os                     = optional(string, "debian-11")
    os_project             = optional(string, "debian-cloud")
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string), ["compute-rw", "storage-rw", "logging-write", "monitoring"])
    network_tags           = optional(list(string))
    healthcheck            = optional(string)
    ssh_key                = optional(string)
    instance_template      = optional(string)
    create_umigs           = optional(bool, true)
    #protocol               = optional(string, "tcp")
    #port                   = optional(number, 80)
    #port_name              = optional(string, "http")
    #use_target_pools     = optional(bool, false)
    nat_interfaces       = optional(list(bool), [false])
    nat_ips              = optional(list(string))
    enable_ip_forwarding = optional(bool, false)
    vpc_network_name     = optional(string, "default")
    vpc_network_names    = optional(list(string))
    subnet_name          = optional(string, "default")
    subnet_names         = optional(list(string))
  })
  default = {}
}

/*
variable "project_id" {
  type    = string
  default = null
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "create" {
  type    = bool
  default = true
}
variable "create_target_pools" {
  type    = bool
  default = false
}
variable "num_instances" {
  type    = number
  default = null
}
variable "naming_prefix" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "region" {
  type    = string
  default = null
}
variable "zone" {
  type    = string
  default = null
}
variable "zones" {
  type    = list(string)
  default = null
}
variable "target_size" {
  type    = number
  default = 2
}
variable "target_pools" {
  type    = list(string)
  default = null
}
variable "healthcheck_id" {
  type    = string
  default = null
}
variable "auto_healing_initial_delay" {
  type    = number
  default = 300
}
variable "machine_type" {
  type    = string
  default = "f1-micro"
}
variable "boot_disk_type" {
  type    = string
  default = "pd-standard"
}
variable "boot_disk_size" {
  type    = number
  default = 10
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
variable "instances" {
  type    = list(string)
  default = null
}
variable "instance_template" {
  type    = string
  default = null
}
variable "base_instance_name" {
  type    = string
  default = null
}
variable "create_umigs" {
  type    = bool
  default = false
}
variable "network_id" {
  type    = string
  default = null
}
variable "vpc_network_name" {
  type    = string
  default = "default"
}
variable "vpc_network_names" {
  type    = list(string)
  default = []
}
variable "subnet_id" {
  type    = string
  default = null
}
variable "subnet_name" {
  type    = string
  default = "default"
}
variable "subnet_names" {
  type    = list(string)
  default = []
}
variable "nat_ips" {
  type    = list(string)
  default = []
}
variable "nat_interfaces" {
  type    = list(bool)
  default = [true]
}
variable "enable_ip_forwarding" {
  type    = bool
  default = false
}
variable "port" {
  type    = number
  default = null
}
variable "protocol" {
  type    = string
  default = null
}
variable "port_name" {
  type    = string
  default = null
}
variable "instance_group_ids" {
  type    = list(string)
  default = null
}
variable "instance_groups" {
  type = map(object({
    zone = string
  }))
  default = null
} */