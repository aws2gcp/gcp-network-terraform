variable "project_id" {
  type    = string
  default = null
}
variable "name" {
  type    = string
  default = null
}
variable "description" {
  type    = string
  default = null
}
variable "logging" {
  type    = bool
  default = false
}
variable "enable_inbound_forwarding" {
  type    = bool
  default = false
}
variable "networks" {
  type    = list(string)
  default = []
}
variable "target_name_servers" {
  type = map(object({
    ipv4_address = string
  }))
}