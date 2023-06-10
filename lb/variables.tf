variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "name_prefix" {
  description = "Name Prefix for this Load Balancer"
  type        = string
  default     = null
  validation {
    condition     = var.name_prefix != null ? length(var.name_prefix) < 50 : true
    error_message = "Name Prefix cannot exceed 49 characters."
  }
}
variable "description" {
  description = "Description for this Load Balancer"
  type        = string
  default     = null
  validation {
    condition     = var.description != null ? length(var.description) < 256 : true
    error_message = "Description cannot exceed 255 characters."
  }
}
variable "classic" {
  description = "Create Classic Load Balancer (or instead use envoy-based platform)"
  type        = bool
  default     = false
}
variable "region" {
  description = "GCP Region Name (regional LB only)"
  type        = string
  default     = null
}
variable "ssl_policy_name" {
  description = "Name of pre-existing SSL Policy to Use for Frontend"
  type        = string
  default     = null
}
variable "tls_profile" {
  description = "If creating SSL profile, the Browser Profile to use"
  type        = string
  default     = null
}
variable "min_tls_version" {
  description = "If creating SSL profile, the Minimum TLS Version to allow"
  type        = string
  default     = null
}
variable "ssl_certs" {
  description = "List of SSL Certificates to upload to Google Certificate Manager"
  type = list(object({
    create      = optional(bool)
    name        = optional(string)
    certificate = optional(string)
    private_key = optional(string)
    description = optional(string)
  }))
  default = null
}
variable "ssl_cert_names" {
  description = "List of existing SSL certificates to apply to this load balancer frontend"
  type        = list(string)
  default     = null
}
variable "use_gmc" {
  description = "Use Google-Managed Certs"
  type        = bool
  default     = false
}
variable "use_ssc" {
  description = "Use Self-Signed Certs"
  type        = bool
  default     = null
}
variable "ssc_valid_years" {
  description = "For self-signed certs, the number of years they should be valid for"
  type        = number
  default     = null
}
variable "ssc_ca_org" {
  description = "For self-signed certs, the name of the fake issuing CA"
  type        = string
  default     = null
}
variable "domains" {
  type    = list(string)
  default = null
}
variable "key_algorithm" {
  description = "For self-signed cert, the Algorithm for the Private Key"
  type        = string
  default     = "RSA"
}
variable "key_bits" {
  description = "For self-signed cert, the number for bits for the private key"
  type        = number
  default     = 2048
}
variable "quic_override" {
  type    = string
  default = null
}
variable "default_service_id" {
  type    = string
  default = null
}
variable "network_name" {
  type    = string
  default = null
}
variable "subnet_name" {
  type    = string
  default = null
}
variable "network_project_id" {
  type    = string
  default = null
}
variable "type" {
  type    = string
  default = null
}
variable "enable_ipv4" {
  type    = bool
  default = true
}
variable "enable_ipv6" {
  type    = bool
  default = false
}
variable "ipv4_address" {
  type    = string
  default = null
}
variable "ipv6_address" {
  type    = string
  default = null
}
variable "ip_address" {
  type    = string
  default = null
}
variable "ip_address_name" {
  type    = string
  default = null
}
variable "port_range" {
  type    = string
  default = null
}
variable "ports" {
  description = "List of Ports Accept traffic on all ports (Network LBs only)"
  type        = list(number)
  default     = null
}
variable "all_ports" {
  description = "Accept traffic on all ports (Network LBs only)"
  type        = bool
  default     = false
}
variable "http_port" {
  description = "HTTP port for LB Frontend"
  type        = number
  default     = 80
}
variable "https_port" {
  description = "HTTPS port for LB Frontend"
  type        = number
  default     = 443
}
variable "forwarding_rule_name" {
  description = "Name For the forwarding Rule"
  type        = string
  default     = null
}
variable "labels" {
  description = "Labels For the forwarding Rule"
  type        = map(string)
  default     = null
}
variable "global_access" {
  type    = bool
  default = false
}
// Begin backend settings
variable "backend_logging" {
  description = "Log requests to all backends (can be overridden on individual backends)"
  type        = bool
  default     = null
}
variable "backend_timeout" {
  description = "Default timeout for all backends in seconds (can be overridden on individual backends)"
  type        = number
  default     = 30
}
variable "cloudarmor_policy" {
  description = "Cloud Armor Policy name to apply to all backends (can be overridden on individual backends)"
  type        = string
  default     = null
}
variable "default_backend" {
  description = "Default backend key to send traffic to. If not provided, first backend key will be used"
  type        = string
  default     = null
}
variable "affinity_type" {
  description = "Session Affinity type all backends (can be overrriden on individual backends)"
  type        = string
  default     = null
}
variable "enable_cdn" {
  description = "Enable CDN for all backends (can be overrriden on individual backends)"
  type        = bool
  default     = null
}
variable "cdn_cache_mode" {
  description = "CDN caching mode for all backends (can be overrriden on individual backends)"
  type        = string
  default     = null
}
// End Backend Settings
variable "create" {
  type    = bool
  default = true
}

variable "healthchecks" {
  type = list(object({
    create              = optional(bool, true)
    project_id          = optional(string)
    name                = optional(string)
    description         = optional(string)
    region              = optional(string)
    port                = optional(number, 80)
    protocol            = optional(string)
    interval            = optional(number, 10)
    timeout             = optional(number, 5)
    healthy_threshold   = optional(number, 2)
    unhealthy_threshold = optional(number, 2)
    request_path        = optional(string)
    response            = optional(string)
    host                = optional(string)
    legacy              = optional(bool)
    logging             = optional(bool)
    proxy_header        = optional(string)
  }))
  default = []
}

variable "psc" {
  description = "Parameters to publish Internal forwarding rule using PSC"
  type = object({
    service_name                = optional(string)
    description                 = optional(string)
    nat_subnet_ids              = optional(list(string))
    nat_subnet_names            = optional(list(string))
    use_proxy_protocol          = optional(bool)
    auto_accept_all_connections = optional(bool)
    accept_project_ids          = optional(list(string))
    reject_project_ids          = optional(list(string))
    connection_limit            = optional(number)
  })
  default = null
}
variable "routing_rules" {
  description = "Route rules to send different hostnames/paths to different backends"
  type = list(object({
    create                    = optional(bool)
    name                      = optional(string)
    priority                  = optional(number)
    hosts                     = list(string)
    backend                   = optional(string)
    backend_name              = optional(string)
    path                      = optional(string)
    request_headers_to_remove = optional(list(string))
    path_rules = optional(list(object({
      paths        = list(string)
      backend_name = optional(string)
      backend      = string
    })))
  }))
  default = null
}
variable "backends" {
  description = "Map of all backend services & buckets"
  type = list(object({
    create             = optional(bool)
    name               = optional(string)
    type               = optional(string) # We'll try and figure it out automatically
    description        = optional(string)
    region             = optional(string)
    bucket_name        = optional(string)
    psc_target         = optional(string)
    port               = optional(number)
    port_name          = optional(string)
    protocol           = optional(string)
    enable_cdn         = optional(bool)
    cdn_cache_mode     = optional(string)
    timeout            = optional(number)
    logging            = optional(bool)
    logging_rate       = optional(number)
    affinity_type      = optional(string)
    locality_lb_policy = optional(string)
    cloudarmor_policy  = optional(string)
    healthcheck        = optional(string)
    healthcheck_names  = optional(list(string))
    healthchecks = optional(list(object({
      id     = optional(string)
      name   = optional(string)
      region = optional(string)
    })))
    groups = optional(list(string)) # List of Instance Group or NEG IDs
    instance_groups = optional(list(object({
      id        = optional(string)
      name      = optional(string)
      zone      = optional(string)
      instances = optional(list(string))
    })))
    rnegs = optional(list(object({
      region                = optional(string)
      psc_target            = optional(string)
      network_name          = optional(string)
      subnet_name           = optional(string)
      cloud_run_name        = optional(string) # Cloud run service name
      app_engine_name       = optional(string) # App Engine service name
      container_image       = optional(string) # Default to GCR if not full URL
      docker_image          = optional(string) # Pull image from docker.io
      container_port        = optional(number) # Cloud run container port
      allow_unauthenticated = optional(bool)
      allowed_members       = optional(list(string))
    })))
    ineg = optional(object({
      fqdn       = optional(string)
      ip_address = optional(string)
      port       = optional(number)
    }))
    iap = optional(object({
      application_title = optional(string)
      support_email     = optional(string)
      members           = optional(list(string))
    }))
    capacity_scaler             = optional(number)
    max_utilization             = optional(number)
    max_rate_per_instance       = optional(number)
    max_connections             = optional(number)
    connection_draining_timeout = optional(number)
    custom_request_headers      = optional(list(string))
    custom_response_headers     = optional(list(string))
  }))
  default = [{
    name = "example"
    ineg = { fqdn = "teapotme.com" }
  }]
}
