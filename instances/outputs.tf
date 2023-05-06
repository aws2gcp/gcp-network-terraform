output "instances" {
  value = {
    for k, v in local.instances : k => v
  }
}
