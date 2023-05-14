variable "project_id" {
  type    = string
  default = null
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "name" {
  type    = string
  default = null
}
variable "region" {
  type    = string
  default = null
}
variable "type" {
  type    = string
  default = null
}
variable "database_version" {
  type    = string
  default = null
}
variable "tier" {
  type    = string
  default = null
}
variable "private_network_id" {
  type    = string
  default = null
}
variable "private_network_name" {
  type    = string
  default = null
}
variable "deletion_projection" {
  type    = bool
  default = null
}
variable "sql_instances" {
  description = "Map of Cloud Sql DB Instances"
  type = map(object({
    project_id           = optional(string)
    network_project_id   = optional(string)
    name                 = optional(string)
    region               = optional(string)
    type                 = optional(string)
    database_version     = optional(string)
    tier                 = optional(string)
    private_network_id   = optional(string)
    private_network_name = optional(string)
    deletion_projection  = optional(bool)
    create               = optional(bool)
  }))
  default = {
    sql-instance = {
      project_id           = null
      network_project_id   = null
      name                 = null
      region               = null
      type                 = null
      database_version     = null
      tier                 = null
      private_network_id   = null
      private_network_name = null
      deletion_projection  = null
      create               = null
    }
  }
}
