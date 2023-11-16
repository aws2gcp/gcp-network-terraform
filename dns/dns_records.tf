locals {
  dns_records_0 = flatten([
    for i, v in local.dns_zones : [
      for r in v.records : {
        project_id   = v.project_id
        managed_zone = v.name
        name         = record.name == "" ? v.dns_name : "${r.name}.${v.dns_name}"
        type         = upper(coalesce(r.type, "A"))
        ttl          = coalesce(r.ttl, 300)
        rrdatas      = coalesce(r.rrdatas, [])
        zone_key     = v.key
      }
    ]
  ])
  dns_records = [for i, v in local.dns_records_0 : merge(v, {
    key = "${v.zone_key}::${v.name}::${v.type}"
  })]
}

# DNS Records
resource "google_dns_record_set" "default" {
  for_each     = { for i, v in local.dns_records : v.key => v }
  project      = each.value.project_id
  managed_zone = each.value.managed_zone
  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
  depends_on   = [google_dns_managed_zone.default]
}
