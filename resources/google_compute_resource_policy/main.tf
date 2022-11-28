resource "google_compute_resource_policy" "default" {
  count  = 1
  region = var.region
  name   = var.name
  snapshot_schedule_policy {
    schedule {
      weekly_schedule {
        day_of_weeks {
          day        = "TUESDAY"
          start_time = "04:00"
        }
      }
    }
    retention_policy {
      max_retention_days    = 30
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }
    snapshot_properties {
      storage_locations = ["us"]
      guest_flush       = false
    }
  }
  project = var.project_id
}
