locals {
  iap_backends = { for k, v in local.backend_services : k => {
    #web_backend_service = coalesce(
    #local.is_global ? google_compute_backend_service.default[k] : null,
    #local.is_regional ? google_compute_region_backend_service.default[k] : null,
    #)
    application_title   = coalesce(var.backends[k].iap.application_title, k)
    support_email       = var.backends[k].iap.support_email
    web_backend_service = v.name
    role                = "roles/iap.httpsResourceAccessor"
    display_name        = k
    members             = var.backends[k].iap.members
  } if v.use_iap == true }
}

resource "google_iap_brand" "default" {
  for_each          = local.iap_backends
  project           = var.project_id
  application_title = each.value.application_title
  support_email     = each.value.support_email
}

resource "google_iap_client" "default" {
  for_each     = local.iap_backends
  display_name = each.value.display_name
  brand        = google_iap_brand.default[each.key].name
}

resource "google_iap_web_backend_service_iam_binding" "default" {
  for_each            = local.iap_backends
  project             = var.project_id
  web_backend_service = each.value.web_backend_service
  role                = each.value.role
  members             = toset(each.value.members)
}
