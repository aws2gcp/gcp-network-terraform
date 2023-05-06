locals {
  dns_records = flatten([
    for k, v in local.dns_zones : [
      for record in v.records : {
        project_id   = v.project_id
        managed_zone = v.name
        key          = "${record.name}-${v.name}"
        name         = record.name == "" ? v.dns_name : "${record.name}.${v.dns_name}"
        type         = upper(coalesce(record.type, "A"))
        ttl          = coalesce(record.ttl, 300)
        rrdatas      = coalesce(record.rrdatas, [])
      }
    ]
  ])
}

# DNS Records
resource "google_dns_record_set" "default" {
  for_each     = { for dns_record in local.dns_records : "${dns_record.key}" => dns_record }
  project      = each.value.project_id
  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  depends_on   = [google_dns_managed_zone.default]
}
