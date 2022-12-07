resource "google_dns_record_set" "default" {
  for_each     = length(var.records) > 0 ? { for record in var.records : record.name => record } : {}
  project      = var.project_id
  managed_zone = var.zone_name
  name         = each.key == null || each.key == "" ? var.dns_name : "${each.key}.${var.dns_name}"
  type         = upper(each.value.type)
  ttl          = coalesce(each.value.ttl, var.default_ttl, 300)
  rrdatas      = coalesce(each.value.rrdatas, [])
}
