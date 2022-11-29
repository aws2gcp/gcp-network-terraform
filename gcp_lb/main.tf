
# GCS Buckets
module "buckets" {
  source   = "../modules/buckets"
  for_each = var.buckets
  name     = each.value.name
  #description = each.value.description
  params = merge(var.bucket_defaults, each.value, {
    region = try(coalesce(each.value.region, var.region), null)
  })
  project_id = var.project_id
}

# Network Endpoint Groups (Serverless and Internet)
module "negs" {
  source      = "../modules/negs"
  for_each    = var.negs
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
  params = merge(var.neg_defaults, each.value, {
    region = try(coalesce(each.value.region, var.region), null)
  })
  project_id = var.project_id
}

# Healthchecks (Global, Regional, and Legacy)
module "healthchecks" {
  source      = "../modules/healthchecks"
  for_each    = var.healthchecks
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
  params = merge(var.healthcheck_defaults, each.value, {
    region = try(coalesce(each.value.region, var.healthcheck_defaults.region), null)
  })
  project_id = var.project_id
}

/* Create Instance Template for each region
module "instance_templates" {
  source             = "../modules/google_compute_instance_template"
  for_each           = var.instances
  project_id         = var.project_id
  network_project_id = coalesce(var.network_project_id, var.project_id)
  name_prefix        = each.value.instance_template != null ? "${var.naming_prefix}-${each.value.region}" : null
  region             = each.value.region
  machine_type       = coalesce(each.value.machine_type, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].machine_type : "a", "a")
  image              = coalesce(each.value.image, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].image : "a", "a")
  os_project         = coalesce(each.value.os_project, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].os_project : "a", "a")
  os                 = coalesce(each.value.os, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].os : "a", "a")
  startup_script     = coalesce(each.value.startup_script, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].startup_script : "a", "a")
  network_tags       = coalesce(each.value.network_tags, each.value.instance_template != null ? var.instance_templates[each.value.instance_template].network_tags : [], [])
  vpc_network_name   = var.vpc_network_name
  subnet_name        = coalesce(each.value.subnet_name, var.instance_defaults.subnet_name, var.subnet_name)
}

# Auto-scaled Managed Instance Groups
module "migs" {
  source                    = "../modules/google_compute_instance_group_manager"
  for_each                  = var.instances
  name                      = each.value.auto_scale == true ? "${var.naming_prefix}-${each.value.region}" : null
  base_instance_name        = var.naming_prefix
  project_id                = var.project_id
  region                    = coalesce(each.value.region, var.region)
  instance_template         = each.value.auto_scale == true ? module.instance_templates[each.key].ids[0] : null
  auto_healing_health_check = each.value.auto_scale == true ? module.healthchecks[var.instance_templates[each.value.instance_template].healthcheck].id : null
} */

# Instances and Instance Groups
module "instances" {
  source     = "../modules/instances"
  for_each   = var.instances
  project_id = var.project_id
  name       = "${var.naming_prefix}-${each.key}"
  region     = try(coalesce(each.value.region, var.instance_defaults.region, var.region), null)
  params     = merge(var.instance_defaults, each.value)
  depends_on = [module.healthchecks]
}

# Backend Services & Backend Buckets
module "backends" {
  source      = "../modules/backends"
  for_each    = var.backends
  name        = coalesce(each.value.name, "${var.naming_prefix}-${each.key}")
  description = each.value.description
  params = merge(var.backend_defaults, each.value, {
    region      = try(coalesce(each.value.region, var.backend_defaults.region, var.region), null)
    bucket_name = each.value.bucket_name != null ? each.value.bucket_name : try(module.buckets[each.value.bucket].name, null)
    neg_id      = try(module.negs[each.value.neg_name].id, null)
  })
  project_id = var.project_id
  depends_on = [module.instances, module.negs, module.buckets]
}

# SSL Certificates
module "ssl-certs" {
  source      = "../modules/ssl_certs"
  for_each    = var.ssl_certs
  name        = coalesce(each.value.name, each.key)
  description = each.value.description
  params      = each.value
  project_id  = var.project_id
}

# Frontends
module "frontends" {
  source      = "../modules/frontends"
  for_each    = var.frontends
  project_id  = var.project_id
  name        = "${var.naming_prefix}-${each.key}"
  description = each.value.description
  params      = merge(var.frontend_defaults, each.value)
  #depends_on  = [module.backends]
}

