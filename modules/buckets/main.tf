locals {
  create_bucket          = var.create
  name                   = local.use_random_name ? lower(random_string.bucket_name[0].result) : lower(var.name)
  description            = try(lower(var.description), null)
  use_random_name        = var.name == null ? true : false
  location               = coalesce(upper(var.params.location), var.region, "US")
  uniform_access_control = upper(substr(var.params.access_control, 0, 4)) == "FINE" ? false : true
  storage_class          = upper(var.params.class)
}

resource "random_string" "bucket_name" {
  count   = local.use_random_name ? 1 : 0
  length  = 63
  special = false
}

resource "google_storage_bucket" "default" {
  count                       = local.create_bucket ? 1 : 0
  name                        = local.name
  location                    = local.location
  storage_class               = local.storage_class
  force_destroy               = var.params.force_destroy
  uniform_bucket_level_access = local.uniform_access_control
  labels                      = coalesce(var.params.labels, {})
  dynamic "versioning" {
    for_each = var.params.versioning ? [true] : []
    content {
      enabled = true
    }
  }
  dynamic "lifecycle_rule" {
    for_each = var.params.lifecycle_rules != null ? var.params.lifecycle_rules : []
    content {
      condition {
        age                        = lifecycle_rule.value.age
        num_newer_versions         = lifecycle_rule.value.num_newer_versions
        days_since_noncurrent_time = lifecycle_rule.value.days_since_noncurrent_time
        matches_prefix             = []
        matches_storage_class      = []
        matches_suffix             = []
        with_state                 = lifecycle_rule.value.with_state != null ? upper(lifecycle_rule.value.with_state) : null
      }
      action {
        type = lifecycle_rule.value.action
      }
    }
  }
  dynamic "cors" {
    for_each = var.params.cors != null ? [true] : []
    content {
      origin          = var.params.cors.origins
      method          = var.params.cors.methods
      max_age_seconds = var.params.cors.max_age
      response_header = var.params.cors.response_header
    }
  }
  project = var.project_id
}