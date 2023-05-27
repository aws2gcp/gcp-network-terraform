locals {
  backend_buckets = [for i, v in local.backends : {
    type        = "bucket"
    name        = v.name
    bucket_name = coalesce(v.bucket_name, v.name, "bucket-${v.name}")
    description = coalesce(v.description, "Backend Bucket '${v.name}'")
    enable_cdn  = coalesce(v.enable_cdn, true) # This is probably static content, so why not?
    create      = coalesce(v.create, true)
  } if try(local.backends[i].type, "unknown") == "bucket" && local.is_http && local.is_global && local.is_external]
}

# Backend Buckets
resource "google_compute_backend_bucket" "default" {
  for_each    = { for i, v in local.backend_buckets : v.name => v if v.create }
  project     = var.project_id
  name        = "${local.name_prefix}-${each.key}"
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn
}
