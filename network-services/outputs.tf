output "mig_names" {
  value = [for k, v in module.mig : v.name]
}
output "ilbs" {
  value = { for k, v in module.ilb : k => {
    name             = v.name
    address          = v.address
    backends         = v.backends
    psc_service_name = lookup(v, "psc", null) != null ? v.psc.service_name : null
  } }
}