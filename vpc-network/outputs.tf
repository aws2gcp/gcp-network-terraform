output "subnets" {
  value = { for k, v in local.subnets : k => {
    name     = v.name
    region   = v.region
    ip_range = v.ip_range
    }
  }
}
output "cloud_nats" {
  value = { for k, v in local.cloud_nats : k => {
    name = v.name
    }
  }
}
