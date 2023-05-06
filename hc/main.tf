locals {
  create_hc       = local.is_global || local.is_regional || local.is_legacy
  name            = local.use_random_name ? lower("${one(random_string.name_prefix).result}-${local.protocol}-${var.port}") : lower(var.name)
  use_random_name = var.name == null ? true : false
  description     = var.description
  is_regional     = var.region != null ? true : false
  is_global       = !local.is_regional ? true : false
  is_legacy       = var.legacy == true ? true : false
  protocol        = upper(coalesce(var.protocol, "tcp"))
  is_tcp          = local.protocol == "TCP" ? true : false
  is_http         = local.protocol == "HTTP" ? true : false
  is_https        = local.protocol == "HTTPS" ? true : false
  is_ssl          = local.protocol == "SSL" ? true : false
  request_path    = local.is_http || local.is_https ? coalesce(var.request_path, "/") : null
  response        = local.is_http || local.is_https ? coalesce(var.response, "OK") : null
  proxy_header    = coalesce(var.proxy_header, "NONE")
}

# Generate a random name prefix, if required
resource "random_string" "name_prefix" {
  count   = local.use_random_name ? 1 : 0
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = false
}

# Global Health Checks
resource "google_compute_health_check" "default" {
  count       = local.is_global && !local.is_legacy ? 1 : 0
  name        = local.name
  description = local.description
  dynamic "tcp_health_check" {
    for_each = local.is_tcp ? [true] : []
    content {
      port         = var.port
      proxy_header = local.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = local.is_http ? [true] : []
    content {
      port         = var.port
      host         = var.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "https_health_check" {
    for_each = local.is_https ? [true] : []
    content {
      port         = var.port
      host         = var.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = local.is_ssl ? [true] : []
    content {
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  check_interval_sec  = var.interval
  timeout_sec         = var.timeout
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  log_config {
    enable = var.logging
  }
  project = var.project_id
}

# Regional Health Checks
resource "google_compute_region_health_check" "default" {
  count       = local.create_hc && local.is_regional && !local.is_legacy ? 1 : 0
  name        = local.name
  description = local.description
  region      = var.region
  dynamic "tcp_health_check" {
    for_each = local.is_tcp ? [true] : []
    content {
      port = var.port
    }
  }
  dynamic "http_health_check" {
    for_each = local.is_http ? [true] : []
    content {
      port         = var.port
      host         = var.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "https_health_check" {
    for_each = local.is_https ? [true] : []
    content {
      port         = var.port
      host         = var.host
      request_path = local.request_path
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = local.is_ssl ? [true] : []
    content {
      proxy_header = local.proxy_header
      response     = local.response
    }
  }
  check_interval_sec  = var.interval
  timeout_sec         = var.timeout
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  log_config {
    enable = var.logging
  }
  project = var.project_id
}

# Legacy HTTP Health Check
resource "google_compute_http_health_check" "default" {
  count              = local.create_hc && local.is_legacy && local.is_http ? 1 : 0
  name               = local.name
  description        = local.description
  port               = var.port
  check_interval_sec = var.interval
  timeout_sec        = var.timeout
  project            = var.project_id
}

# Legacy HTTPS Health Check
resource "google_compute_https_health_check" "default" {
  count              = local.create_hc && local.is_legacy && local.is_https ? 1 : 0
  name               = local.name
  description        = local.description
  port               = var.port
  check_interval_sec = var.interval
  timeout_sec        = var.timeout
  project            = var.project_id
}

