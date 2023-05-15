variable "project_id" {
  type    = string
  default = null
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "network_name" {
  type    = string
  default = "default"
}
variable "instances" {
  type = map(object({
    create                 = optional(bool)
    project_id             = optional(string)
    name                   = optional(string)
    description            = optional(string)
    region                 = optional(string)
    zone                   = optional(string)
    num_instances          = optional(string)
    subnet_name            = optional(string)
    machine_type           = optional(string)
    boot_disk_type         = optional(string)
    boot_disk_size         = optional(number)
    labels                 = optional(map(string))
    image                  = optional(string)
    os                     = optional(string)
    os_project             = optional(string)
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string))
    network_tags           = optional(list(string))
    enable_ip_forwarding   = optional(bool)
    deletion_protection    = optional(bool)
    nat_ip_addresses       = optional(list(string))
    nat_ip_names           = optional(list(string))
    ssh_key                = optional(string)
    create_instance_groups = optional(bool)
    public_zone            = optional(string)
    private_zone           = optional(string)
    roles = optional(list(object({
      role    = string
      members = optional(list(string))
    })))
  }))
  default = {}
}
