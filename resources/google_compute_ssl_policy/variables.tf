variable "name" {
  description = "Name of the SSL profile"
  type        = string
}

variable "description" {
  description = "Description of the SSL profile"
  type        = string
  default     = null
}

variable "profile" {
  type    = string
  default = "MODERN"
}

variable "min_tls_version" {
  type    = string
  default = "TLS_1_2"
}
