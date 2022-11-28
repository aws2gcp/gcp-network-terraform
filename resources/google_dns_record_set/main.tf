resource "google_dns_record_set" "default" {
  for_each     = var.zone_name != null ? var.records : {}
  project      = var.project_id
  managed_zone = var.zone_name
  name         = "${each.key}.${var.dns_name}"
  type         = upper(each.value.type)
  ttl          = coalesce(each.value.ttl, var.default_ttl)
  rrdatas      = coalesce(each.value.rrdatas, [])
}
