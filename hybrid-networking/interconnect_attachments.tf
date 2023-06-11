locals {
  interconnect_attachments_0 = flatten([
    for i, v in var.interconnects : [
      for c, circuit in v.ciruits : {
        create            = coalesce(v.create, true)
        is_interconnect   = true
        is_vpn            = false
        project_id        = coalesce(v.project_id, var.project_id)
        name              = coalesce(v.name, "interconnect-${i}-${c}")
        description       = v.description
        region            = coalesce(v.region, var.region)
        interconnect_type = upper(coalesce(v.type, "PARTNER"))
        ip_range          = circuit.cloud_router_ip
        mtu               = coalesce(circuit.mtu, v.mtu, 1440)
        enable            = coalesce(circuit.enable, true)
      }
    ]
  ])
  interconnect_attachments = [
    for i, v in local.interconnect_attachments_0 : merge(v, {
      key = "${v.project_id}-${v.region}-${v.name}"
    })
  ]
}

# Interconnect Attachment
resource "google_compute_interconnect_attachment" "default" {
  for_each                 = { for i, v in local.interconnect_attachments : v.key => v if v.create }
  project                  = each.value.project_id
  name                     = each.value.name
  description              = each.value.description
  region                   = each.value.region
  router                   = each.value.router
  ipsec_internal_addresses = []
  encryption               = each.value.encryption
  mtu                      = each.value.mtu
  admin_enabled            = each.value.enable
  type                     = each.value.interconnect_type
  interconnect             = each.value.interconnect_type == "DEDICATED" ? each.value.interconnect : null
  depends_on               = [google_compute_router.default]
}
