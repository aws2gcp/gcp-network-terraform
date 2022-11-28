/*
output "instances" {
  value = {
    for k, v in module.instances : k => {
      names = v.name
    }
  }
}
*/
/*
output "migs" {
  value = {
    for k, v in module.migs : k => [
      for i, name in v.names : { name = name, zone = v.zones[i] }
    ]
  }
} */

output "buckets" {
  value = {
    for k, v in module.buckets : k => {
      name     = v.name
      location = v.location
    }
  }
}
output "negs" {
  value = {
    for k, v in module.negs : k => {
      id   = v.id
      name = v.name
    }
  }
}
/*
output "backends" {
  value = {
    for k, v in module.backends : k => {
      lb_scheme = v.lb_scheme
      protocol  = v.protocol
    }
  }
}
output "frontends" {
  value = {
    for k, v in module.frontends : k => {
      address = v.address
    }
  }
}
*/