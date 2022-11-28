variable "project_id" {
  description = "Project ID of GCP Project"
  type        = string
}
variable "naming_prefix" {
  description = "Prefix to apply to all backend/frontends"
  type        = string
}
variable "vpc_network_name" {
  description = "Name of VPC Network to deploy Frontend to (internal LB only)"
  type        = string
  default     = null
}
variable "subnet_name" {
  description = "Name of Subnet for LB Frontend and any backend instances (can be overridden)"
  type        = string
  default     = null
}
variable "network_project_id" {
  description = "Project ID of Host Network (if using a shared VPC)"
  type        = string
  default     = null
}
variable "region" {
  description = "Default GCP region name for all resources (can be overridden)"
  type        = string
  default     = null
}
variable "healthcheck_defaults" {
  description = "Default values for all healthchecks (can be overridden)"
  type = object({
    port         = optional(number)
    protocol     = optional(string)
    interval     = optional(number)
    timeout      = optional(number)
    request_path = optional(string)
    response     = optional(string)
  })
  default = {}
}
variable "healthchecks" {
  description = "Map of Health Checks and their parameters"
  type = map(object({
    port         = optional(number)
    protocol     = optional(string)
    interval     = optional(number)
    timeout      = optional(number)
    request_path = optional(string)
    response     = optional(string)
    regional     = optional(bool)
    legacy       = optional(bool)
    create       = optional(bool)
    description  = optional(string)
  }))
  default = {}
}
variable "instance_templates" {
  type = map(object({
    create                 = optional(bool, true)
    region                 = optional(string)
    vpc_network_name       = optional(string)
    subnet_name            = optional(string)
    network_tags           = optional(list(string), [])
    machine_type           = optional(string, "f1-micro")
    image                  = optional(string, "debian-cloud/debian-11")
    os                     = optional(string, "debian-11")
    os_project             = optional(string, "debian-cloud")
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string), ["compute-rw", "storage-rw", "logging-write", "monitoring"])
    healthcheck            = optional(string)
  }))
  default = {}
}
variable "instance_defaults" {
  type = object({
    region                = optional(string)
    num_instances         = optional(number)
    subnet_name           = optional(string)
    machine_type          = optional(string)
    image                 = optional(string)
    os                    = optional(string)
    os_project            = optional(string)
    service_account_email = optional(string)
    network_tags          = optional(list(string), [])
    startup_script        = optional(string)
    healthcheck           = optional(string)
    use_target_pools      = optional(bool, false)
  })
  default = {}
}
variable "instances" {
  type = map(object({
    create                 = optional(bool, true)
    region                 = optional(string)
    zone                   = optional(string)
    zones                  = optional(list(string))
    auto_scale             = optional(bool, false)
    num_instances          = optional(string)
    vpc_network_name       = optional(string)
    subnet_name            = optional(string)
    machine_type           = optional(string)
    image                  = optional(string)
    os                     = optional(string)
    os_project             = optional(string)
    startup_script         = optional(string)
    service_account_email  = optional(string)
    service_account_scopes = optional(list(string))
    network_tags           = optional(list(string))
    healthcheck            = optional(string)
    affinity_type          = optional(string)
    use_target_pools       = optional(bool)
    instance_template      = optional(string)
    create_umig            = optional(bool, true)
  }))
  default = {}
}
variable "migs" {
  description = "Managed Instance Groups"
  type = map(object({
    description        = optional(string)
    region             = optional(string)
    zones              = optional(list(string))
    target_shape       = optional(string, "even")
    instances_template = string
    autoscale_mode     = optional(string, "on")
    min_instances      = optional(number, 1)
    max_instances      = optional(number, 10)
  }))
  default = {}
}
variable "umigs" {
  description = "Unmanaged Instance Groups"
  type = map(object({
    create    = optional(bool, false)
    zone      = string
    instances = optional(list(string), [])
  }))
  default = {}
}
variable "bucket_defaults" {
  type = object({
    create         = optional(bool, true)
    location       = optional(string)
    region         = optional(string)
    access_control = optional(string)
  })
  default = {}
}
variable "buckets" {
  description = "Map of Google Cloud Storage Buckets"
  type = map(object({
    name           = optional(string)
    description    = optional(string)
    location       = optional(string)
    region         = optional(string)
    access_control = optional(string)
    versioning     = optional(bool)
    labels         = optional(map(any))
    lifecycle_rules = optional(list(object({
      age                        = optional(number)
      days_since_noncurrent_time = optional(number)
      num_newer_versions         = optional(number)
      with_state                 = optional(string)
      action                     = string
    })))
    cors = optional(object({
      max_age         = optional(number)
      methods         = optional(list(string))
      origins         = optional(list(string))
      response_header = optional(list(string))
    }))
  }))
  default = {}
}
variable "backend_defaults" {
  description = "Default settings for all backends (can be overridden)"
  type = object({
    type   = optional(string)
    region = optional(string)
    instance_groups = optional(map(object({
      zone = string
    })))
    port              = optional(number)
    protocol          = optional(string)
    healthcheck       = optional(string)
    enable_logging    = optional(bool)
    timeout           = optional(number)
    balancing_mode    = optional(string)
    affinity_type     = optional(string)
    cloudarmor_policy = optional(string)
    enable_cdn        = optional(bool)
    cdn_cache_mode    = optional(string)
    bucket            = optional(string)
    bucket_name       = optional(string)
  })
  default = {}
}
variable "backends" {
  description = "Map of backends for this load balancer"
  type = map(object({
    create      = optional(bool, true)
    type        = optional(string)
    description = optional(string)
    ne_group    = optional(string)
    port        = optional(number)
    port_name   = optional(string)
    protocol    = optional(string)
    instances   = optional(string)
    instance_groups = optional(map(object({
      zone = string
    })))
    balancing_mode        = optional(string)
    timeout               = optional(number)
    region                = optional(string)
    healthcheck           = optional(string)
    enable_logging        = optional(bool)
    affinity_type         = optional(string)
    cloudarmor_policy     = optional(string)
    enable_cdn            = optional(bool)
    cdn_cache_mode        = optional(string)
    bucket                = optional(string)
    bucket_name           = optional(string)
    ip_address            = optional(string)
    fqdn                  = optional(string)
    cloud_function_name   = optional(string)
    cloud_run_name        = optional(string)
    app_engine_service    = optional(string)
    app_engine_version_id = optional(string)
    auto_scale            = optional(bool)
  }))
  default = {}
}
variable "frontend_defaults" {
  description = "Default settings for all Frontends (can be overridden in each frontend)"
  type = object({
    type                   = optional(string)
    protocol               = optional(string)
    subnet_name            = optional(string)
    port                   = optional(number)
    ports                  = optional(list(string), [])
    allow_global_access    = optional(bool)
    http_port              = optional(number)
    https_port             = optional(number)
    enable_http            = optional(bool)
    enable_https           = optional(bool)
    redirect_http_to_https = optional(bool)
    ssl_policy_name        = optional(string)
    region                 = optional(string)
    use_target_pools       = optional(bool)
    classic                = optional(bool)
  })
  default = {}
}
variable "frontends" {
  description = "Map of frontends (forwarding rules)"
  type = map(object({
    create                       = optional(bool, true)
    type                         = optional(string)
    protocol                     = optional(string)
    region                       = optional(string)
    subnet_name                  = optional(string)
    ip_address                   = optional(string)
    port                         = optional(number)
    ports                        = optional(list(string))
    http_port                    = optional(number)
    https_port                   = optional(number)
    allow_global_access          = optional(bool)
    use_target_pools             = optional(bool)
    network_project_id           = optional(string)
    enable_http                  = optional(bool)
    enable_https                 = optional(bool)
    redirect_http_to_https       = optional(bool)
    ssl_certificates             = optional(list(string))
    psc_name                     = optional(string)
    psc_subnet_names             = optional(list(string))
    psc_auto_accept_all_projects = optional(bool)
    psc_accept_project_ids       = optional(list(string))
    default_backend              = optional(string)
    route_rules = optional(list(object({
      hostnames = list(string)
      backend   = optional(string)
      path_rules = optional(list(object({
        paths   = list(string)
        backend = string
      })))
    })))
    classic = optional(bool)
  }))
  default = {}
}
variable "ssl_certificates" {
  description = "Map of existing SSL Certificates to upload to Google Certificate Manager"
  type = map(object({
    description = optional(string)
    domains     = optional(list(string))
    certificate = optional(string)
    private_key = optional(string)
  }))
  default = {
    self-signed-cert = {
      certificate = "localhost.crt"
      private_key = "localhost.key"
    }
  }
}
