locals {
  sql_instances = {
    for k, v in var.sql_instances : k => {
      project_id          = coalesce(v.project_id, var.project_id)
      name                = coalesce(v.name, var.name, k)
      region              = coalesce(v.region, var.region, "us-central1")
      type                = lower(coalesce(v.type, var.type, "mysql"))
      database_version    = try(coalesce(v.database_version, var.database_version), null)
      tier                = coalesce(v.tier, var.tier, "db-f1-micro")
      network_project_id  = coalesce(v.network_project_id, var.network_project_id, v.project_id, var.project_id)
      network_link        = try(coalesce(v.private_network_id, var.private_network_id), null)
      network_name        = coalesce(v.private_network_name, var.private_network_name, "default")
      deletion_protection = coalesce(v.deletion_projection, var.deletion_projection, true)
    }
  }
  default_versions = {
    mysql    = "MYSQL_8_0"
    postgres = "POSTGRES_14"
    mssql    = "SQLSERVER_2019_STANDARD"
  }
  sql_instances_with_version = {
    for k, v in local.sql_instances : k => merge(v, {
      database_version = upper(coalesce(v.database_version, lookup(local.default_versions, v.type, "NONE")))
      network_link     = coalesce(v.network_link, "projects/${v.network_project_id}/global/networks/${v.network_name}")
    })
  }
}
resource "google_sql_database_instance" "default" {
  for_each            = local.sql_instances_with_version
  name                = each.value.name
  region              = each.value.region
  database_version    = each.value.database_version
  deletion_protection = each.value.deletion_protection
  settings {
    tier = each.value.tier
    ip_configuration {
      ipv4_enabled    = each.value.network_link == null ? true : false
      private_network = each.value.network_link
    }
  }
  project = var.project_id
}
