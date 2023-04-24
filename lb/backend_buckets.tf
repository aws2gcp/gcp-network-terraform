locals {
  backend_buckets = { for k, v in var.backends : k => {
    type        = "bucket"
    bucket_name = coalesce(v.bucket_name, k)
    description = coalesce(v.description, "Backend Bucket '${k}'")
    enable_cdn  = coalesce(v.enable_cdn, true) # This is probably static content, so why not?
  } if try(local.backends[k].type, "unknown") == "bucket" && local.is_http && local.is_global && local.is_external }
}

# Backend Buckets
resource "google_compute_backend_bucket" "default" {
  for_each    = local.backend_buckets
  project     = var.project_id
  name        = "${local.name_prefix}-${each.key}"
  bucket_name = each.value.bucket_name
  description = each.value.description
  enable_cdn  = each.value.enable_cdn
}
