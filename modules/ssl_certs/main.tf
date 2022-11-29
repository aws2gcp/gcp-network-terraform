locals {
  create                   = coalesce(var.create, true)
  name                     = lower(coalesce(var.name, local.generated_name))
  name_prefix              = "${local.name}-"
  description              = try(lower(var.description), null)
  is_global                = !var.params.regional || var.params.region == null ? true : false
  is_regional              = var.params.regional && var.params.region != null ? true : false
  upload_ssl_certs         = var.params.certificate != null && var.params.private_key != null ? true : false
  create_google_ssl_certs  = local.create && var.params.domains == null ? false : length(var.params.domains) > 0 ? true : false
  create_self_signed_cert  = local.create && !local.create_google_ssl_certs && !local.upload_ssl_certs ? true : false
  generated_name           = local.create_google_ssl_certs ? replace(var.params.domains[0], ".", "-") : local.self_signed_cert_domain
  self_signed_valid_hours  = coalesce(var.params.self_signed_valid_hours, 24 * local.self_signed_valid_days)
  self_signed_valid_days   = coalesce(var.params.self_signed_valid_days, 365 * local.self_signed_valid_years)
  self_signed_valid_years  = coalesce(var.params.self_signed_valid_years, 10)
  self_signed_key_algo     = "RSA"
  self_signed_key_length   = 2048
  self_signed_cert_domain  = "localhost-localdomain"
  self_signed_cert_org     = "Intended for demonstration purposes or temporary use"
  self_signed_allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]
  #ssl_certificates    = local.upload_ssl_certs ? [for k, v in var.params.ssl_certi    ficates : google_compute_ssl_certificate.default[k].id] : null
  private_key = local.upload_ssl_certs ? file("${path.module}/${var.params.private_key}") : null
  certificate = local.upload_ssl_certs ? file("${path.module}/${var.params.certificate}") : null
}

# If required, create RSA private key
resource "tls_private_key" "default" {
  count     = local.create_self_signed_cert ? 1 : 0
  algorithm = local.self_signed_key_algo
  rsa_bits  = local.self_signed_key_length
}

# If required, create a self-signed cert off the private key
resource "tls_self_signed_cert" "default" {
  count           = local.create_self_signed_cert ? 1 : 0
  private_key_pem = one(tls_private_key.default).private_key_pem
  subject {
    common_name  = local.self_signed_cert_domain
    organization = local.self_signed_cert_org
  }
  validity_period_hours = local.self_signed_valid_hours
  allowed_uses          = local.self_signed_allowed_uses
}

# Imported SSL Certificates (Global)
resource "google_compute_ssl_certificate" "default" {
  count       = local.upload_ssl_certs || local.create_self_signed_cert && local.is_global ? 1 : 0
  name        = local.upload_ssl_certs ? local.name : null
  name_prefix = local.create_self_signed_cert ? local.name_prefix : null
  description = local.description
  certificate = local.upload_ssl_certs ? local.certificate : one(tls_self_signed_cert.default).cert_pem
  private_key = local.upload_ssl_certs ? local.private_key : one(tls_private_key.default).private_key_pem
  lifecycle {
    create_before_destroy = true
  }
  project = var.project_id
}

# Imported SSL Certificates (Regional)
resource "google_compute_region_ssl_certificate" "default" {
  count       = local.upload_ssl_certs || local.create_self_signed_cert && local.is_regional ? 1 : 0
  name        = local.upload_ssl_certs ? local.name : null
  name_prefix = local.create_self_signed_cert ? local.name_prefix : null
  description = local.description
  certificate = local.upload_ssl_certs ? local.certificate : one(tls_self_signed_cert.default).cert_pem
  private_key = local.upload_ssl_certs ? local.private_key : one(tls_private_key.default).private_key_pem
  lifecycle {
    create_before_destroy = true
  }
  region  = var.params.region
  project = var.project_id
}

# Google-Managed SSL certificates (Global only)
resource "google_compute_managed_ssl_certificate" "default" {
  count       = local.create_google_ssl_certs && local.is_global ? 1 : 0
  name        = local.name
  description = local.description
  managed {
    domains = var.params.domains
  }
  project = var.project_id
}