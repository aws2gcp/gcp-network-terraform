output "cloud_sql_instances" {
  value = { for k, v in local.sql_instances_with_version : k =>
    {
      name = try(google_sql_database_instance.default[k].name, null)
    }
  }
}
