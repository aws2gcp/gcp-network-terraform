# Custom SSL Certificates
resource "google_compute_ssl_certificate" "default" {
  for_each    = local.upload_ssl_certs ? var.params.ssl_certificates : {}
  name        = each.key
  project     = var.project_id
  private_key = file("${path.module}/${each.value.private_key}")
  certificate = file("${path.module}/${each.value.certificate}")
  lifecycle {
    create_before_destroy = true
  }
}