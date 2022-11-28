variable "name" {
  type = string
}
variable "instance_template" {
  type = string
}
variable "zones" {
  type    = list(string)
  default = null
}
variable "region" {
  type    = string
  default = null
}
variable "target_pools" {
  type = list(string)
}
variable "auto_healing_health_check" {
  type = string
}
variable "auto_healing_initial_delay" {
  type    = number
  default = 300
}

