locals {
  create                 = coalesce(var.create, true)
  name                   = lower(coalesce(var.name, "backend-${local.use_bucket ? "bucket" : "service"}"))
  description            = try(lower(var.description), null)
  create_backend_service = local.create && local.use_neg || local.use_igs ? true : false
  create_backend_bucket  = local.create && local.use_bucket ? true : false
  use_bucket             = var.params.bucket_name != null ? true : false
  use_neg                = var.params.neg_id != null || var.params.neg_name != null ? true : false
  use_igs                = local.use_neg || local.use_bucket ? false : true
  is_regional            = var.params.regional || !local.is_classic && var.params.neg_region != null ? true : false
  is_global              = local.is_classic || local.use_bucket ? true : false
  is_classic             = coalesce(var.params.classic, false)
  use_healthchecks       = local.use_neg || local.use_bucket ? false : true
}
