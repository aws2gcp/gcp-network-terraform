locals {
  default_balancing_mode = local.type == "TCP" ? "CONNECTION" : "UTILIZATION"
  hc_prefix              = "projects/${var.project_id}/${local.is_regional ? "regions/${var.region}" : "global"}/healthChecks"
  backend_services = { for k, v in var.backends : k => {
    create = coalesce(v.create, true)
    # Determine backend type by seeing if a key has been created for IG, SNEG, or INEG
    type            = try(local.backends[k].type, "unknown")
    name            = "${local.name_prefix}-${k}"
    description     = coalesce(v.description, "Backend Service '${k}'")
    region          = local.is_regional ? coalesce(v.region, local.region) : null # Set region, if required
    protocol        = lookup(local.rnegs, k, null) != null ? null : local.is_http ? upper(coalesce(v.protocol, try(one(local.new_inegs[k]).protocol, null), "https")) : (local.is_tcp ? "TCP" : null)
    port_name       = local.is_http ? coalesce(v.port, 80) == 80 ? "http" : coalesce(v.port_name, "${k}-${coalesce(v.port, 80)}") : null
    timeout         = try(local.backends[k].type, "unknown") == "rneg" ? null : coalesce(v.timeout, var.backend_timeout, 30)
    healthcheck_ids = v.healthchecks != null ? [for hc in v.healthchecks : coalesce(hc.id, try("${local.hc_prefix}/${hc.name}", null))] : []
    groups = coalesce(v.groups,
      try(local.backends[k].type, "unknown") == "igs" && lookup(local.instance_groups, k, null) != null ? local.instance_groups[k].ids : null,
      try(local.backends[k].type, "unknown") == "rneg" ? [for rneg in local.new_rnegs : google_compute_region_network_endpoint_group.default[rneg.key].id if rneg.backend == k] : null,
      try(local.backends[k].type, "unknown") == "ineg" && lookup(local.new_inegs, k, null) != null ? [google_compute_global_network_endpoint_group.default[k].id] : null,
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
    max_rate_per_instance       = local.is_managed ? coalesce(v.max_rate_per_instance, 512) : null
    connection_draining_timeout = coalesce(v.connection_draining_timeout, 300)
    custom_request_headers      = v.custom_request_headers
    custom_response_headers     = v.custom_response_headers
    use_iap                     = local.is_http && v.iap != null ? true : false
  } if contains(["igs", "rneg", "ineg"], try(local.backends[k].type, "unknown")) }
}

# Global Backend Service
resource "google_compute_backend_service" "default" {
  for_each                        = local.is_global ? { for k, v in local.backend_services : k => v if v.create } : {}
  project                         = var.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = local.lb_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.type == "rneg" ? "HTTPS" : each.value.protocol
  port_name                       = each.value.type == "igs" ? each.value.port_name : null
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.type == "igs" ? local.backend_services[each.key].healthcheck_ids : null
  session_affinity                = each.value.type == "igs" ? each.value.affinity_type : null
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  custom_request_headers          = each.value.custom_request_headers
  custom_response_headers         = each.value.custom_response_headers
  security_policy                 = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = local.backend_services[each.key].capacity_scaler
      balancing_mode        = each.value.type == "ineg" ? null : local.default_balancing_mode
      max_rate_per_instance = each.value.type == "igs" ? local.backend_services[each.key].max_rate_per_instance : null
      max_utilization       = each.value.type == "igs" ? local.backend_services[each.key].max_utilization : null
      max_connections       = each.value.type == "igs" ? local.backend_services[each.key].max_connections : null
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
  dynamic "iap" {
    for_each = each.value.use_iap ? [true] : []
    content {
      oauth2_client_id     = google_iap_client.default[each.key].client_id
      oauth2_client_secret = google_iap_client.default[each.key].secret
    }
  }
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
  for_each                        = local.is_regional ? local.backend_services : {}
  project                         = var.project_id
  name                            = each.value.name
  description                     = each.value.description
  load_balancing_scheme           = local.lb_scheme
  locality_lb_policy              = each.value.locality_lb_policy
  protocol                        = each.value.type == "rneg" ? "HTTPS" : each.value.protocol
  port_name                       = each.value.type == "igs" ? each.value.port_name : null
  timeout_sec                     = each.value.timeout
  health_checks                   = each.value.type == "igs" ? local.backend_services[each.key].healthcheck_ids : null
  session_affinity                = each.value.type == "igs" ? each.value.affinity_type : null
  connection_draining_timeout_sec = each.value.connection_draining_timeout
  #security_policy = each.value.security_policy
  dynamic "backend" {
    for_each = each.value.groups
    content {
      group                 = backend.value
      capacity_scaler       = local.backend_services[each.key].capacity_scaler
      balancing_mode        = each.value.type == "ineg" ? null : local.default_balancing_mode
      max_rate_per_instance = each.value.type == "igs" ? local.backend_services[each.key].max_rate_per_instance : null
      max_utilization       = each.value.type == "igs" ? local.backend_services[each.key].max_utilization : null
      max_connections       = each.value.type == "igs" ? local.backend_services[each.key].max_connections : null
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
