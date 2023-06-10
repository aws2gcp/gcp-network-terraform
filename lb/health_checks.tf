locals {
  healthchecks_0 = [for i, v in var.healthchecks : merge(v, {
    create       = coalesce(v.create, true)
    project_id   = coalesce(v.project_id, var.project_id)
    name         = lower(v.name)
    region       = local.is_regional ? coalesce(v.region, var.region) : null
    is_regional  = local.is_regional
    is_global    = local.is_global
    protocol     = upper(coalesce(v.protocol, "tcp"))
    proxy_header = coalesce(v.proxy_header, "NONE")
  })]
  healthchecks_1 = [for i, v in local.healthchecks_0 : merge(v, {
    is_tcp   = v.protocol == "TCP" ? true : false
    is_http  = v.protocol == "HTTP" ? true : false
    is_https = v.protocol == "HTTPS" ? true : false
    is_ssl   = v.protocol == "SSL" ? true : false
  })]
  healthchecks = [for i, v in local.healthchecks_1 : merge(v, {
    request_path = v.is_http || v.is_https ? coalesce(v.request_path, "/") : null
    response     = v.is_http || v.is_https ? coalesce(v.response, "OK") : null
  })]
}

# Global Health Checks
resource "google_compute_health_check" "default" {
  for_each    = { for i, v in local.healthchecks : v.name => v if v.create && v.is_global }
  name        = each.value.name
  description = each.value.description
  dynamic "tcp_health_check" {
    for_each = each.value.is_tcp ? [true] : []
    content {
      port         = each.value.port
      proxy_header = each.value.proxy_header
    }
  }
  dynamic "http_health_check" {
    for_each = each.value.is_http ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "https_health_check" {
    for_each = each.value.is_https ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = each.value.is_ssl ? [true] : []
    content {
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  check_interval_sec  = each.value.interval
  timeout_sec         = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  log_config {
    enable = each.value.logging
  }
  project = each.value.project_id
}

# Regional Health Checks
resource "google_compute_region_health_check" "default" {
  for_each    = { for i, v in local.healthchecks : v.name => v if v.create && v.is_regional }
  name        = each.value.name
  description = each.value.description
  dynamic "tcp_health_check" {
    for_each = each.value.is_tcp ? [true] : []
    content {
      port = each.value.port
    }
  }
  dynamic "http_health_check" {
    for_each = each.value.is_http ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "https_health_check" {
    for_each = each.value.is_https ? [true] : []
    content {
      port         = each.value.port
      host         = each.value.host
      request_path = each.value.request_path
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  dynamic "ssl_health_check" {
    for_each = each.value.is_ssl ? [true] : []
    content {
      proxy_header = each.value.proxy_header
      response     = each.value.response
    }
  }
  check_interval_sec  = each.value.interval
  timeout_sec         = each.value.timeout
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  log_config {
    enable = each.value.logging
  }
  project = each.value.project_id
  region  = each.value.region
}
