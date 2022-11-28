# Global URL Map for HTTP 
resource "google_compute_url_map" "http" {
  count           = var.create && local.is_global && local.create_http ? 1 : 0
  name            = local.name
  default_service = local.is_http && var.params.redirect_to_https ? null : local.backend_service_id
  dynamic "default_url_redirect" {
    for_each = var.params.redirect_to_https == true ? [true] : []
    content {
      strip_query            = var.strip_query_on_redirect
      redirect_response_code = var.params.redirect_http_to_https == false ? var.params.redirect_response_code : null
      https_redirect         = var.params.redirect_http_to_https == true ? true : null
    }
  }
  dynamic "host_rule" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      hosts        = host_rule.value.hostnames
      path_matcher = "path-matcher-${host_rule.key}"
    }
  }
  dynamic "path_matcher" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      name            = "path-matcher-${path_matcher.key}"
      default_service = coalesce(path_matcher.value["backend"], local.backend_service_id)
      dynamic "path_rule" {
        for_each = coalesce(path_matcher.value["path_rules"], [])
        content {
          paths   = path_rule.value["paths"]
          service = path_rule.value["backend"]
        }
      }
    }
  }
}
# Global URL Map for HTTP 
resource "google_compute_url_map" "https" {
  count           = var.create && local.is_global && local.create_https ? 1 : 0
  name            = local.name
  default_service = local.is_https ? local.backend_service_id : null
  dynamic "host_rule" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      hosts        = host_rule.value.hostnames
      path_matcher = "path-matcher-${host_rule.key}"
    }
  }
  dynamic "path_matcher" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      name            = "path-matcher-${path_matcher.key}"
      default_service = coalesce(path_matcher.value["backend"], local.backend_service_id)
      dynamic "path_rule" {
        for_each = coalesce(path_matcher.value["path_rules"], [])
        content {
          paths   = path_rule.value["paths"]
          service = path_rule.value["backend"]
        }
      }
    }
  }
}

# Regional URL Map for HTTP 
resource "google_compute_region_url_map" "http" {
  count           = var.create && local.is_regional && local.create_http ? 1 : 0
  name            = local.name
  region          = var.region
  default_service = local.is_http && var.params.redirect_to_https == true ? null : local.backend_service_id
  dynamic "default_url_redirect" {
    for_each = var.params.redirect_to_https == true ? [true] : []
    content {
      strip_query            = var.strip_query_on_redirect
      redirect_response_code = var.params.redirect_to_https == false ? var.params.redirect_response_code : null
      https_redirect         = var.params.redirect_to_https == true ? true : null
    }
  }
  dynamic "host_rule" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      hosts        = host_rule.value.hostnames
      path_matcher = "path-matcher-${host_rule.key}"
    }
  }
  dynamic "path_matcher" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      name            = "path-matcher-${path_matcher.key}"
      default_service = coalesce(path_matcher.value["backend"], local.backend_service_id)
      dynamic "path_rule" {
        for_each = coalesce(path_matcher.value["path_rules"], [])
        content {
          paths   = path_rule.value["paths"]
          service = path_rule.value["backend"]
        }
      }
    }
  }
}
resource "google_compute_region_url_map" "https" {
  count           = var.create && local.is_regional && local.create_https ? 1 : 0
  name            = local.name
  region          = var.region
  default_service = local.is_https ? local.backend_service_id : null
  dynamic "host_rule" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      hosts        = host_rule.value.hostnames
      path_matcher = "path-matcher-${host_rule.key}"
    }
  }
  dynamic "path_matcher" {
    for_each = coalesce(var.params.route_rules, [])
    content {
      name            = "path-matcher-${path_matcher.key}"
      default_service = coalesce(path_matcher.value["backend"], local.backend_service_id)
      dynamic "path_rule" {
        for_each = coalesce(path_matcher.value["path_rules"], [])
        content {
          paths   = path_rule.value["paths"]
          service = path_rule.value["backend"]
        }
      }
    }
  }
}