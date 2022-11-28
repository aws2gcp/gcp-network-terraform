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
variable "ne_type" {
  type    = string
  default = "ip_address"
}
variable "default_port" {
  type    = number
  default = 443
}
