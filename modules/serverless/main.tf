locals {
  create            = coalesce(var.create, true)
  use_random_name   = var.name == null ? true : false
  name              = local.use_random_name ? try(lower(one(random_string.name).result), null) : lower(var.name)
  description       = try(lower(var.description), null)
  is_cloud_function = false
  version           = local.is_cloud_function ? var.params.cloud_function_version : null
  is_cloud_run      = var.params.image != null ? true : false
  is_app_engine     = false
  location          = lower(var.params.region)
  timeout           = var.params.timeout
}

# Generate a random name, if required
resource "random_string" "name" {
  count   = local.use_random_name ? 1 : 0
  length  = 31
  special = false
}

# Cloud Function v1
resource "google_cloudfunctions_function" "default" {
  count                 = local.create && local.is_cloud_function && local.version == 1 ? 1 : 0
  name                  = local.name
  description           = local.description
  region                = var.params.region
  runtime               = var.params.runtime
  available_memory_mb   = var.params.available_memory
  trigger_http          = var.params.trigger_http
  entry_point           = var.params.entry_point
  environment_variables = var.params.environment_variables
  timeout               = local.timeout
  project               = var.project_id
}

# Cloud Function v2
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
    available_memory               = "${upper(var.params.available_memory)}${var.params.available_memory > 999 ? "G" : "M"}"
    min_instance_count             = var.params.min_instances
    max_instance_count             = var.params.max_instances
    timeout_seconds                = var.params.timeout
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    #versions {
    #  version = "latest"
    #}
  }
  project = var.project_id
}

# Cloud Run Service
resource "google_cloud_run_service" "default" {
  count    = local.create && local.is_cloud_run ? 1 : 0
  name     = local.name
  location = local.location
  template {
    spec {
      containers {
        image = var.params.image
        ports {
          name = "http1"
          #protocol       = "TCP"
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

# App Engine
resource "google_app_engine_application" "default" {
  count       = local.create && local.is_app_engine ? 1 : 0
  location_id = local.location
  project     = var.project_id
}