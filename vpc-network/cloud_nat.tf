# Allocate Static IP for each Cloud NAT, if required
locals {
  cloud_nat_addresses = { for k, v in var.cloud_nats : k => [
    for i, nat_address in coalesce(v.static_ips, []) : {
      name         = coalesce(nat_address.name, "cloudnat-${var.network_name}-${v.region}-${i}")
      description  = nat_address.description
      address_type = "EXTERNAL"
      network_tier = "PREMIUM"
      region       = v.region
      address      = nat_address.address
    }
  ] if length(coalesce(v.static_ips, [])) > 0 }
  addresses = flatten([
    for k, addresses in local.cloud_nat_addresses : [
      for i, address in coalesce(addresses, []) : merge(address, {
        key = "${k}-${i}"
      })
    ]
  ])
}
resource "google_compute_address" "default" {
  for_each     = { for address in local.addresses : "${address.key}" => address }
  project      = var.project_id
  name         = each.value.name
  description  = each.value.description
  address_type = each.value.address_type
  network_tier = each.value.network_tier
  region       = each.value.region
  address      = each.value.address
}

# Cloud NATs (NAT Gateways)
locals {
  router_names = { for k, v in var.cloud_routers : k => v.name }
  cloud_nats_with_log_type = {
    for k, v in var.cloud_nats : k => merge(v, {
      name                   = coalesce(v.name, "${var.network_name}-${v.region}")
      router                 = coalesce(v.cloud_router_name, try(local.router_names[v.cloud_router], "unknown"))
      nat_ip_allocate_option = length(coalesce(v.static_ips, [])) > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
      subnets                = coalesce(v.subnets, [])
      enable_dpa             = coalesce(v.enable_dpa, var.defaults.cloud_nat_enable_dpa)
      enable_eim             = coalesce(v.enable_eim, var.defaults.cloud_nat_enable_eim)
      min_ports_per_vm       = coalesce(v.min_ports_per_vm, v.enable_dpa != false ? 32 : 64)
      max_ports_per_vm       = v.enable_dpa != false ? coalesce(v.max_ports_per_vm, 65536) : null
      log_type               = lower(coalesce(v.log_type, "none"))
      udp_idle_timeout       = coalesce(v.udp_idle_timeout, var.defaults.cloud_nat_udp_idle_timeout)
      tcp_est_idle_timeout   = coalesce(v.tcp_established_idle_timeout, var.defaults.cloud_nat_tcp_established_idle_timeout)
      tcp_trans_idle_timeout = coalesce(v.tcp_transitory_idle_timeout, var.defaults.cloud_nat_tcp_transitory_idle_timeout)
      icmp_idle_timeout      = coalesce(v.icmp_idle_timeout, var.defaults.cloud_nat_icmp_idle_timeout)
    })
  }
  log_filter = {
    "errors"       = "ERRORS_ONLY"
    "translations" = "TRANSLATIONS_ONLY"
    "all"          = "ALL"
  }
  cloud_nats = {
    for k, v in local.cloud_nats_with_log_type : k => merge(v, {
      logging          = v.log_type != "none" ? true : false
      log_filter       = lookup(local.log_filter, v.log_type, "ERRORS_ONLY")
      ip_ranges_to_nat = length(v.subnets) > 0 ? "LIST_OF_SUBNETWORKS" : "ALL_SUBNETWORKS_ALL_IP_RANGES"
    })
  }
}
resource "google_compute_router_nat" "default" {
  for_each                           = local.cloud_nats
  project                            = var.project_id
  name                               = each.value.name
  router                             = each.value.router
  region                             = each.value.region
  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  nat_ips                            = [for address in local.cloud_nat_addresses[each.key] : address.name]
  source_subnetwork_ip_ranges_to_nat = each.value.ip_ranges_to_nat
  dynamic "subnetwork" {
    for_each = each.value.subnets
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_dynamic_port_allocation      = each.value.enable_dpa
  enable_endpoint_independent_mapping = each.value.enable_eim
  log_config {
    enable = each.value.logging
    filter = each.value.log_filter
  }
  udp_idle_timeout_sec             = each.value.udp_idle_timeout
  tcp_established_idle_timeout_sec = each.value.tcp_est_idle_timeout
  tcp_transitory_idle_timeout_sec  = each.value.tcp_trans_idle_timeout
  icmp_idle_timeout_sec            = each.value.icmp_idle_timeout
}