locals {
  enable_http  = var.http_port != null ? true : false
  enable_https = var.https_port != null ? true : false
}

# Global URL Map for HTTP
resource "google_compute_url_map" "http" {
  count           = local.is_http && local.is_global && local.enable_http ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-http"
  default_service = null
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# Regional URL Map for HTTP
resource "google_compute_region_url_map" "http" {
  count           = local.is_http && local.is_regional && local.enable_http ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-http"
  default_service = null
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
  region = local.region
}

locals {
  # Get the IDs for each backend.  It should be a global backend bucket or service, or a regional backend service
  backend_ids = { for i, v in local.backends : v.name =>
    try(coalesce(
      v.type == "bucket" && local.is_global ? google_compute_backend_bucket.default[v.name].id : null,
      v.type != "bucket" && local.is_global ? google_compute_backend_service.default[v.name].id : null,
      v.type != "bucket" && local.is_regional ? google_compute_region_backend_service.default[v.name].id : null,
    ), null)
  }
  default_service_id = lookup(local.backend_ids, coalesce(var.default_backend, local.backends[0].name), "error")
  routing_rules = [for i, v in coalesce(var.routing_rules, []) : merge(v, {
    name       = coalesce(v.name, "path-matcher-${i + 1}")
    hosts      = [for host in v.hosts : length(split(".", host)) > 1 ? host : "${host}.${var.domains[0]}"]
    path_rules = coalesce(v.path_rules, [])
  })]
}

# Global HTTPS URL MAP
resource "google_compute_url_map" "https" {
  count           = local.create && local.is_http && local.is_global && local.enable_https ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-https"
  default_service = local.default_service_id
  dynamic "host_rule" {
    for_each = local.routing_rules
    content {
      path_matcher = host_rule.value.name
      hosts        = host_rule.value.hosts
    }
  }
  dynamic "path_matcher" {
    for_each = local.routing_rules
    content {
      name            = path_matcher.value.name
      default_service = lookup(local.backend_ids, coalesce(path_matcher.value.backend, path_matcher.key), null)
      dynamic "route_rules" {
        for_each = path_matcher.value.request_headers_to_remove != null ? [true] : []
        content {
          priority = coalesce(path_matcher.value.priority, 1)
          service  = lookup(local.backend_ids, coalesce(path_matcher.value.backend, path_matcher.key), null)
          match_rules {
            prefix_match = coalesce(path_matcher.value.path, "/")
          }
          header_action {
            request_headers_to_remove = path_matcher.value.request_headers_to_remove
          }
        }
      }
      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.backend
        }
      }
    }
  }
  depends_on = [google_compute_backend_service.default, google_compute_backend_bucket.default]
}
# Regional HTTPS URL MAP
resource "google_compute_region_url_map" "https" {
  count           = local.create && local.is_http && local.is_regional && local.enable_https ? 1 : 0
  project         = var.project_id
  name            = "${local.name_prefix}-https"
  default_service = local.default_service_id
  dynamic "host_rule" {
    for_each = local.routing_rules
    content {
      path_matcher = host_rule.value.name
      hosts        = host_rule.value.hosts
    }
  }
  dynamic "path_matcher" {
    for_each = local.routing_rules
    content {
      name            = path_matcher.value.name
      default_service = lookup(local.backend_ids, coalesce(path_matcher.value.backend, path_matcher.key), null)
      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = path_rule.value.backend
        }
      }
    }
  }
  depends_on = [google_compute_region_backend_service.default, google_compute_backend_bucket.default]
  region     = local.region
}
