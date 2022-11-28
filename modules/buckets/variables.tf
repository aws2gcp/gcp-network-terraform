variable "project_id" {
  description = "Project ID for these Beautiful Resources"
  type        = string
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
  description = "Parameters for this GCS Bucket"
  type = object({
    name           = optional(string)
    location       = optional(string, "US")
    region         = optional(string)
    class          = optional(string, "STANDARD")
    access_control = optional(string, "UNIFORM")
    versioning     = optional(bool, false)
    labels         = optional(map(any), {})
    force_destroy  = optional(bool, false)
    lifecycle_rules = optional(list(object({
      age                        = optional(number, 0)
      days_since_noncurrent_time = optional(number, 0)
      num_newer_versions         = optional(number)
      with_state                 = optional(string)
      action                     = string
    })))
    cors = optional(object({
      max_age         = optional(number, 0)
      max_age_seconds = optional(number, 3600)
      methods         = optional(list(string), ["GET"])
      origins         = optional(list(string), ["*"])
      response_header = optional(list(string), ["*"])
    }))
  })
  default = {}
}