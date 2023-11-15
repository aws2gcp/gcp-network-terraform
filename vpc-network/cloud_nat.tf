# Allocate Static IP for each Cloud NAT, if required
locals {
  cloud_router_names = { for i, v in local.cloud_routers : v.name => v.name }
  cloud_nats_0 = [for i, v in coalesce(var.cloud_nats, []) : merge(v, {
    create                 = coalesce(v.create, true)
    project_id             = coalesce(v.project_id, var.project_id)
    name                   = coalesce(v.name, "nat-${i}")
    network_name           = coalesce(var.network_name, "default")
    region                 = coalesce(v.region, var.region)
    router                 = coalesce(v.cloud_router_name, try(local.cloud_router_names[v.cloud_router], null), v.name)
    num_static_ips         = coalesce(v.num_static_ips, 0)
    static_ips             = coalesce(v.static_ips, [])
    subnets                = coalesce(v.subnets, [])
    enable_dpa             = coalesce(v.enable_dpa, var.defaults.cloud_nat_enable_dpa)
    enable_eim             = coalesce(v.enable_eim, var.defaults.cloud_nat_enable_eim)
    min_ports_per_vm       = coalesce(v.min_ports_per_vm, var.defaults.cloud_nat_min_ports_per_vm, v.enable_dpa != false ? 32 : 64)
    max_ports_per_vm       = v.enable_dpa != false ? coalesce(v.max_ports_per_vm, var.defaults.cloud_nat_max_ports_per_vm, 65536) : null
    log_type               = lower(coalesce(v.log_type, var.defaults.cloud_nat_log_type))
    udp_idle_timeout       = coalesce(v.udp_idle_timeout, var.defaults.cloud_nat_udp_idle_timeout)
    tcp_est_idle_timeout   = coalesce(v.tcp_established_idle_timeout, var.defaults.cloud_nat_tcp_established_idle_timeout)
    tcp_time_wait_timeout  = coalesce(v.tcp_time_wait_timeout, var.defaults.cloud_nat_tcp_time_wait_timeout)
    tcp_trans_idle_timeout = coalesce(v.tcp_transitory_idle_timeout, var.defaults.cloud_nat_tcp_transitory_idle_timeout)
    icmp_idle_timeout      = coalesce(v.icmp_idle_timeout, var.defaults.cloud_nat_icmp_idle_timeout)
    drain_nat_ips          = []
  })]
  cloud_nats_1 = [for i, v in local.cloud_nats_0 : merge(v, {
    key = "${v.project_id}::${v.region}::${v.name}"
  })]
  nat_addresses = { for i, v in local.cloud_nats_1 : v.key => [
    for a in range(v.num_static_ips) : {
      name        = null
      description = null
      address     = null
    } if v.num_static_ips > 0
  ] }
  cloud_nat_addresses = { for i, v in local.cloud_nats_1 : v.key => [
    for a, nat_address in(length(v.static_ips) > 0 ? v.static_ips : local.nat_addresses[v.key]) : {
      project_id  = coalesce(v.project_id, var.project_id)
      region      = coalesce(v.region, var.region)
      name        = coalesce(nat_address.name, "cloudnat-${v.network_name}-${v.region}-${a}")
      description = nat_address.description
      address     = nat_address.address
    }
  ] if length(v.static_ips) > 0 || v.num_static_ips > 0 }
  addresses = flatten([
    for k, addresses in local.cloud_nat_addresses : [
      for i, address in coalesce(addresses, []) : merge(address, {
        key = "${k}::${i}"
      })
    ]
  ])
}

# External IP Address Allocations for Cloud NATs using static IP(s)
resource "google_compute_address" "cloud_nat" {
  for_each     = { for address in local.addresses : address.key => address }
  project      = var.project_id
  name         = each.value.name
  description  = each.value.description
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = each.value.region
  address      = each.value.address
}

# Cloud NATs (NAT Gateways)
locals {
  log_filter = {
    "errors"       = "ERRORS_ONLY"
    "translations" = "TRANSLATIONS_ONLY"
    "all"          = "ALL"
  }
  cloud_nats_2 = [for i, v in local.cloud_nats_1 : merge(v, {
    nat_ip_allocate_option = length(v.static_ips) > 0 || v.num_static_ips > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  })]
  cloud_nats = [for i, v in local.cloud_nats_2 : merge(v, {
    logging                 = v.log_type == "none" ? false : true
    log_filter              = lookup(local.log_filter, v.log_type, "ERRORS_ONLY")
    source_ip_ranges_to_nat = length(v.subnets) > 0 ? "LIST_OF_SUBNETWORKS" : "ALL_SUBNETWORKS_ALL_IP_RANGES"
  })]
}

resource "google_compute_router_nat" "default" {
  for_each                           = { for i, v in local.cloud_nats : v.key => v if v.create }
  project                            = var.project_id
  name                               = each.value.name
  router                             = each.value.router
  region                             = each.value.region
  nat_ip_allocate_option             = each.value.nat_ip_allocate_option
  nat_ips                            = try([for address in local.cloud_nat_addresses[each.key] : address.name], null)
  source_subnetwork_ip_ranges_to_nat = each.value.source_ip_ranges_to_nat
  dynamic "subnetwork" {
    for_each = each.value.subnets
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = each.value.ip_ranges_to_nat
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
  tcp_time_wait_timeout_sec        = each.value.tcp_time_wait_timeout
  tcp_transitory_idle_timeout_sec  = each.value.tcp_trans_idle_timeout
  icmp_idle_timeout_sec            = each.value.icmp_idle_timeout
  drain_nat_ips                    = each.value.drain_nat_ips
  depends_on                       = [google_compute_address.cloud_nat, google_compute_router.default]
}
