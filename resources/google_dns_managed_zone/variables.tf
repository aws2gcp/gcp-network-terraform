variable "project_id" {
  type        = string
  description = "Google Project ID"
  default     = null
}
variable "name" {
  type        = string
  description = "The Google Cloud Name of this domain (i.e. 'whatever-com')"
  default     = null
}
variable "description" {
  type        = string
  description = "Description of the DNS Zone"
  default     = "Managed by Terraform"
}
variable "dns_name" {
  type        = string
  description = "The DNS name of the domain including trailing dot (i.e. 'whatever.com.')"
}
variable "visibility" {
  type    = string
  default = "public"
}
variable "visible_networks" {
  type        = list(string)
  description = "For private zones, list of VPC network names that can access this zone"
  default     = []
}
variable "logging" {
  type        = bool
  description = "Log DNS queries"
  default     = false
}
