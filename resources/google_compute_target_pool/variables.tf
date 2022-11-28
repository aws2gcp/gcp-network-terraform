variable "project_id" {
  type    = string
  default = null
}
variable "name" {
  type = string
}
variable "region" {
  type    = string
  default = null
}
variable "instances" {
  type    = list(string)
  default = []
}
variable "healthcheck_names" {
  type = list(string)
}
variable "affinity_type" {
  type    = string
  default = "NONE"
}
