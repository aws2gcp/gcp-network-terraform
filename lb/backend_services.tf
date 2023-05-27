locals {
  default_balancing_mode = local.type == "TCP" ? "CONNECTION" : "UTILIZATION"
  hc_prefix              = "projects/${var.project_id}/${local.is_regional ? "regions/${var.region}" : "global"}/healthChecks"
  backend_services = flatten([for i, v in local.backends : [merge(v, {
    description     = coalesce(v.description, "Backend Service '${i}'")
    region          = local.is_regional ? coalesce(v.region, local.region) : null # Set region, if required
    protocol        = v.type == "rneg" ? null : local.is_http ? upper(coalesce(v.protocol, try(one(local.new_inegs[i]).protocol, null), "https")) : (local.is_tcp ? "TCP" : null)
    port_name       = local.is_http ? coalesce(v.port, 80) == 80 ? "http" : coalesce(v.port_name, "${v.name}-${coalesce(v.port, 80)}") : null
    timeout         = try(local.backends[i].type, "unknown") == "rneg" ? null : coalesce(v.timeout, var.backend_timeout, 30)
    healthcheck_ids = v.healthchecks != null ? [for hc in v.healthchecks : coalesce(hc.id, try("${local.hc_prefix}/${hc.name}", null))] : []
    groups = coalesce(v.groups,
      v.type == "igs" ? flatten([for ig_index, ig in local.instance_groups : ig.id if ig.backend_name == v.name]) : null,
      #v.type == "rneg" ? flatten([for rneg_index, rneg in local.new_rnegs : google_compute_region_network_endpoint_group.default["${rneg.backend_name}-${rneg_index}"].id if rneg.backend_name == v.name]) : null,
      #v.type == "ineg" ? flatten([for ineg_index, ineg in local.new_inegs : google_compute_global_network_endpoint_group.default["${ineg.backend_name}-${ineg_index}"].id if ineg.backend_name == v.name]) : null,
      [] # This will result in 'has no backends configured' which is easier to troubleshoot than an ugly error
    )
    logging                     = coalesce(v.logging, var.backend_logging, false)
    logging_rate                = local.is_http ? coalesce(v.logging_rate, 1.0) : 1
    enable_cdn                  = local.is_http && local.is_global ? coalesce(v.enable_cdn, var.enable_cdn, true) : null
    cdn_cache_mode              = local.is_http && local.is_global ? upper(coalesce(v.cdn_cache_mode, var.cdn_cache_mode, "CACHE_ALL_STATIC")) : null
    cdn_default_ttl             = 3600
    cdn_min_ttl                 = 60
    cdn_max_ttl                 = 14400
    cdn_client_ttl              = 3600
    security_policy             = local.is_http ? try(coalesce(v.cloudarmor_policy, var.cloudarmor_policy), null) : null
    affinity_type               = upper(coalesce(v.affinity_type, var.affinity_type, "NONE"))
    locality_lb_policy          = local.is_managed ? upper(coalesce(v.locality_lb_policy, "ROUND_ROBIN")) : null
    capacity_scaler             = local.is_managed ? coalesce(v.capacity_scaler, 1.0) : null
    max_connections             = local.is_global && local.is_tcp ? coalesce(v.max_connections, 32768) : null
    max_utilization             = local.is_managed ? coalesce(v.max_utilization, 0.8) : null
    max_rate_per_instance       = local.is_managed && v.max_rate_per_instance != null ? v.max_rate_per_instance : null
    connection_draining_timeout = coalesce(v.connection_draining_timeout, 300)
    custom_request_headers      = v.custom_request_headers
    custom_response_headers     = v.custom_response_headers
    use_iap                     = v.use_iap
  })] if contains(["igs", "rneg", "ineg"], try(local.backends[i].type, "unknown"))])
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  for_each                        = local.is_global ? { for i, v in local.backend_services : v.name => v if v.create } : {}
  project                         = var.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = local.lb_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.type == "rneg" ? "HTTPS" : each.value.protocol
  port_name                       = each.value.type == "igs" ? each.value.port_name : null
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.type == "igs" ? each.value.healthcheck_ids : null
  session_affinity                = each.value.type == "igs" ? each.value.affinity_type : null
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  custom_request_headers          = each.value.custom_request_headers
  custom_response_headers         = each.value.custom_response_headers
  security_policy                 = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.type == "ineg" ? null : local.default_balancing_mode
      max_rate_per_instance = each.value.type == "igs" ? each.value.max_rate_per_instance : null
      max_utilization       = each.value.type == "igs" ? each.value.max_utilization : null
      max_connections       = each.value.type == "igs" ? each.value.max_connections : null
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.logging_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  /*
  dynamic "iap" {
    for_each = each.value.use_iap ? [true] : []
    content {
      oauth2_client_id     = google_iap_client.default[each.key].client_id
      oauth2_client_secret = google_iap_client.default[each.key].secret
    }
  }
  */
  enable_cdn = var.enable_cdn
  dynamic "cdn_policy" {
    for_each = var.enable_cdn == true ? [true] : []
    content {
      cache_mode                   = each.value.cdn_cache_mode
      signed_url_cache_max_age_sec = 3600
      default_ttl                  = each.value.cdn_default_ttl
      client_ttl                   = each.value.cdn_client_ttl
      max_ttl                      = each.value.cdn_max_ttl
      negative_caching             = false
      cache_key_policy {
        include_host           = true
        include_protocol       = true
        include_query_string   = true
        query_string_blacklist = []
        query_string_whitelist = []
      }
    }
  }
  depends_on = [google_compute_instance_group.default, google_compute_region_network_endpoint_group.default]
  provider   = google-beta
}

# Regional Backend Service
resource "google_compute_region_backend_service" "default" {
  for_each                        = { for i, v in local.backend_services : v.name => v if v.create && local.is_regional }
  project                         = var.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = local.lb_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.type == "rneg" ? "HTTPS" : each.value.protocol
  port_name                       = each.value.type == "igs" ? each.value.port_name : null
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.type == "igs" ? each.value.healthcheck_ids : null
  session_affinity                = each.value.type == "igs" ? each.value.affinity_type : null
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  #security_policy = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = each.value.capacity_scaler
      balancing_mode        = each.value.type == "ineg" ? null : local.default_balancing_mode
      max_rate_per_instance = each.value.type == "igs" ? each.value.max_rate_per_instance : null
      max_utilization       = each.value.type == "igs" ? each.value.max_utilization : null
      max_connections       = each.value.type == "igs" ? each.value.max_connections : null
    }
  }
  dynamic "log_config" {
    for_each = each.value.logging ? [true] : []
    content {
      enable      = true
      sample_rate = each.value.logging_rate
    }
  }
  dynamic "consistent_hash" {
    for_each = each.value.locality_lb_policy == "RING_HASH" ? [true] : []
    content {
      minimum_ring_size = 1
    }
  }
  region     = each.value.region
  depends_on = [google_compute_instance_group.default, google_compute_region_network_endpoint_group.default]
}
