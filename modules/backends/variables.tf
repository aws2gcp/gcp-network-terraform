variable "project_id" {
  description = "Project ID for these Beautiful Resources"
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
  description = "Parameters of this LB Backend"
  type = object({
    type        = optional(string)
    classic     = optional(bool, false)
    bucket_name = optional(string)
    neg_id      = optional(string)
    neg_name    = optional(string)
    neg_region  = optional(string)
    port        = optional(number, 80)
    port_name   = optional(string, "http")
    protocol    = optional(string)
    #instance_ids       = optional(list(string))
    instance_group_ids = optional(list(string))
    instance_groups = optional(list(object({
      name = string
      zone = string
    })))
    balancing_mode        = optional(string)
    timeout               = optional(number)
    healthcheck_id        = optional(string)
    healthcheck_name      = optional(string)
    enable_logging        = optional(bool, false)
    log_sample_rate       = optional(number, 1.0)
    affinity_type         = optional(string)
    cloudarmor_policy     = optional(string)
    enable_cdn            = optional(bool)
    cdn_cache_mode        = optional(string)
    regional              = optional(bool, false)
    region                = optional(string)
    use_target_pools      = optional(bool, false)
    max_utilization       = optional(number, 0.8)
    max_rate_per_instance = optional(number, 1000)
    max_connections       = optional(number, 4096)
    capacity_scaler       = optional(number, 1.0)
  })
  default = {}
}