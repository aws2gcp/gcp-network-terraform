locals {
  name                   = lower(coalesce(var.name, "backend-${local.is_bucket ? "bucket" : "service"}"))
  description            = try(lower(var.description), null)
  create_backend_service = var.create && local.is_service ? true : false
  is_bucket              = var.params.bucket_name != null ? true : false
  is_neg                 = var.params.neg_id != null || var.params.neg_name != null ? true : false
  is_service             = !local.is_bucket ? true : false
  is_global              = !local.is_bucket && local.is_neg || var.region == null ? true : false
  is_regional            = !local.is_bucket && !local.is_neg && var.region != null ? true : false
}
