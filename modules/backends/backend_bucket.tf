# Backend Bucket
resource "google_compute_backend_bucket" "default" {
  count       = local.create_backend_bucket ? 1 : 0
  name        = local.name
  description = local.description
  bucket_name = var.params.bucket_name
  enable_cdn  = var.params.enable_cdn
}