variable "project_id" {
  type = string
}
variable "name" {
  type    = string
  default = "terraform-regional-neg"
}
variable "region" {
  type    = string
  default = null
}
variable "ne_type" {
  type    = string
  default = "SERVERLESS"
}
variable "cloud_function_name" {
  description = "Name of Cloud Function"
  type        = string
  default     = null
}
variable "cloud_run_name" {
  description = "Name of Cloud Run"
  type        = string
  default     = null
}
variable "app_engine_service" {
  description = "Name of App Engine Service"
  type        = string
  default     = null
}
variable "app_engine_version_id" {
  description = "Version ID of App Engine Service"
  type        = string
  default     = null
}
