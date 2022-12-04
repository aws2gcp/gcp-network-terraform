locals {
  create            = coalesce(var.create, true)
  name              = local.use_random_name ? try(lower(one(random_string.name).result), null) : lower(var.name)
  description       = try(lower(var.description), null)
  use_random_name   = var.name == null ? true : false
  is_cloud_function = false
  is_cloud_run      = var.params.image != null ? true : false
  is_app_engine     = false
  version           = 1
  location          = lower(var.params.region)
}

resource "random_string" "name" {
  count   = local.use_random_name ? 1 : 0
  length  = 31
  special = false
}

resource "google_cloudfunctions_function" "default" {
  count               = local.create && local.is_cloud_function && local.version == 1 ? 1 : 0
  name                = local.name
  description         = local.description
  runtime             = var.params.runtime
  available_memory_mb = var.params.available_memory
  #source_archive_bucket = google_storage_bucket.bucket.name
  #source_archive_object = google_storage_bucket_object.archive.name
  trigger_http = var.params.trigger_http
  entry_point  = var.params.entry_point
  project      = var.project_id
}

resource "google_cloudfunctions2_function" "default" {
  count       = local.create && local.is_cloud_function && local.version == 2 ? 1 : 0
  name        = local.name
  description = local.description
  location    = local.location
  build_config {
    runtime     = var.params.runtime
    entry_point = var.params.entry_point
  }
  service_config {
    available_memory   = "${upper(var.params.available_memory)}${var.params.available_memory > 1000 ? "G" : "M"}"
    min_instance_count = var.params.min_instances
    max_instance_count = var.params.max_instances
    timeout_seconds    = var.params.timeout
  }
  project = var.project_id
}

resource "google_cloud_run_service" "default" {
  count    = local.create && local.is_cloud_run ? 1 : 0
  name     = local.name
  location = local.location
  template {
    spec {
      containers {
        image = var.params.image
        ports {
          protocol       = "TCP"
          container_port = var.params.container_ports[0]
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  project = var.project_id
}

resource "google_app_engine_application" "default" {
  count       = local.create && local.is_app_engine ? 1 : 0
  location_id = local.location
  project     = var.project_id
}