locals {
  create                 = coalesce(var.create, true)
  name_prefix            = var.name_prefix != null ? var.name_prefix : random_string.name_prefix[0].result
  is_global              = var.region == null ? true : false
  is_regional            = local.is_global ? false : true
  is_classic             = local.is_global && var.classic == true ? true : false
  uses_ssl               = local.upload_ssl_certs || local.use_ssc || local.use_gmc ? true : false
  type                   = var.ports != null || var.all_ports ? "TCP" : "HTTP"
  is_tcp                 = local.type == "TCP" ? true : false
  is_ssl                 = local.type == "SSL" ? true : false
  is_http                = local.is_classic || startswith(local.type, "HTTP") || var.routing_rules != {} && !local.is_tcp ? true : false
  is_internal            = var.subnet_name != null ? true : false
  is_external            = local.is_internal ? false : true
  lb_scheme              = local.is_http ? local.http_lb_scheme : (local.is_internal ? "INTERNAL" : "EXTERNAL")
  http_lb_scheme         = local.is_internal ? "INTERNAL_MANAGED" : (local.is_classic ? "EXTERNAL" : "EXTERNAL_MANAGED")
  is_managed             = endswith(local.lb_scheme, "_MANAGED")
  region                 = coalesce(var.region, "us-central1") # SNEGs need a region, even if backend is global
  http_port              = 80
  https_port             = 443
  network_tier           = local.is_managed && local.is_external ? "STANDARD" : null
  purpose                = local.is_managed && local.is_internal ? "SHARED_LOADBALANCER_VIP" : null
  network_name           = coalesce(var.network_name, "default")
  network_project_id     = coalesce(var.network_project_id, var.project_id) # needed for Shared VPC scenarios
  network_link           = "projects/${local.network_project_id}/global/networks/${local.network_name}"
  network                = local.is_managed ? local.network_link : null
  subnet_prefix          = "projects/${local.network_project_id}/regions"
  subnet_id              = local.is_internal ? "${local.subnet_prefix}/${var.region}/subnetworks/${var.subnet_name}" : null
  subnetwork             = local.is_internal ? local.subnet_id : null
  global_access          = local.is_internal ? coalesce(var.global_access, false) : false
  is_mirroring_collector = local.is_internal ? false : null
  labels                 = coalesce(var.labels, {})
  # Do a quick walk over the backends to determine which type each is.  This will help error checking later.
  backend_groups_ids = { for k, backend in var.backends : k => [for group in coalesce(backend.groups, []) : group] }
  backends = [for i, v in var.backends : {
    type = coalesce(v.type,
      lookup(local.instance_groups, i, null) != null ? "igs" : null,
      length(coalesce(lookup(v, "instance_groups", null), [])) > 0 ? "igs" : null,
      length(coalesce(lookup(v, "healthchecks", null), [])) > 0 ? "igs" : null,
      length(coalesce(lookup(v, "rnegs", null), [])) > 0 ? "rneg" : null,
      lookup(v, "ineg", null) != null ? "ineg" : null,
      lookup(v, "bucket_name", null) != null ? "bucket" : null,
      "unknown" # this should never happen
    )
  } if v.create != false]
}

# Generate a random 8-character string for name_prefix, if required
resource "random_string" "name_prefix" {
  count   = var.name_prefix == null ? 1 : 0
  length  = 8
  upper   = false
  special = false
  numeric = false
}
