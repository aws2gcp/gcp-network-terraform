locals {
  create              = coalesce(var.create, true)
  name                = lower(coalesce(var.name, "tf-frontend"))
  description         = try(lower(var.description), null)
  is_global           = var.params.region == null ? true : false
  is_regional         = var.params.region != null ? true : false
  type                = upper(coalesce(var.params.type, local.subnet_id != null ? "INTERNAL" : "EXTERNAL"))
  is_internal         = startswith(local.type, "INTERNAL") ? true : false
  is_external         = startswith(local.type, "EXTERNAL") ? true : false
  is_classic          = var.params.classic
  network_project_id  = coalesce(var.params.network_project_id, var.project_id)
  subnet_prefix       = local.is_regional ? "projects/${local.network_project_id}/regions/${var.params.region}/subnetworks" : "/"
  subnet_id           = try(coalesce(var.params.subnet_id, var.params.subnet_name != null && local.is_regional ? "${local.subnet_prefix}/${var.params.subnet_name}" : null), null)
  network_tier        = local.is_regional || local.type == "INTERNAL" ? "STANDARD" : "PREMIUM"
  purpose             = local.is_internal && local.is_http ? "SHARED_LOADBALANCER_VIP" : null
  protocol            = upper(coalesce(var.params.protocol, "tcp"))
  is_http             = var.params.enable_http == true || var.params.http_port != null || local.protocol == "HTTP" ? true : false
  is_https            = var.params.enable_https == true || var.params.https_port != null || local.protocol == "HTTPS" ? true : false
  create_http         = var.params.enable_http == false ? false : local.is_http
  create_https        = var.params.enable_https == false ? false : local.is_https
  is_tcp              = local.is_http || local.is_https ? false : true
  lb_scheme           = local.is_http ? (local.type == "INTERNAL" || !local.is_classic ? "${local.type}_MANAGED" : local.type) : local.type
  http_port           = local.is_http ? coalesce(var.params.http_port, 80) : null
  https_port          = local.is_https ? coalesce(var.params.https_port, 443) : null
  http_port_range     = local.is_http ? local.http_port : null
  https_port_range    = local.is_https ? local.https_port : null
  ports               = local.is_http || local.is_https ? [] : length(var.params.ports) > 0 ? var.params.ports : [var.params.port]
  all_ports           = length(var.params.ports) > 0 || var.params.port != null || local.is_http || local.is_https ? false : true
  backend_prefix      = local.is_regional ? "projects/${var.project_id}/regions/${var.params.region}/backendServices" : "projects/${var.project_id}/global/backendServices"
  backend_service_id  = try(coalesce(var.params.default_backend != null ? "${local.backend_prefix}/${var.params.default_backend}" : null), null)
  http_target         = local.create_http ? one(concat(google_compute_target_http_proxy.default.*.id, google_compute_region_target_http_proxy.default.*.id)) : null
  https_target        = local.create_https ? one(concat(google_compute_target_https_proxy.default.*.id, google_compute_region_target_https_proxy.default.*.id)) : null
  psc_nat_subnets     = var.params.psc_nat_subnets != null ? [for sn in var.params.psc_nat_subnets : "${local.subnet_prefix}/${sn}"] : null
  upload_ssl_certs    = var.params.ssl_certificates != null && local.create_https ? true : false
  ssl_certificates    = var.params.ssl_certs #local.upload_ssl_certs ? [for k, v in var.params.ssl_certificates : google_compute_ssl_certificate.default[k].id] : null
  redirect_to_https   = local.is_http ? var.params.redirect_to_https : false
  psc_connection_pref = var.params.psc_auto_accept_all_projects ? "ACCEPT_AUTOMATIC" : "ACCEPT_MANUAL"
}

