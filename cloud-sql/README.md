# Google Cloud Platform Cloud SQL Instance

## Resources 

- [google_sql_database_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance)

## Inputs 


| Name                | Description                         | Type      | Default       |
|---------------------|-------------------------------------|-----------|---------------|
| project_id          | Project ID of the GCP project       | `string`  | n/a           |
| region              | GCP Region Name                     | `string`  | us-central1   |
| name                | Name of the Database Instance       | `string`  | sql-instance  |
| type                | Type of DB (mysql, mssql, postgres) | `string`  | mysql         |
| database_version    | Database Version                    | `string`  | MYSQL_8_0     |
| tier                | Instance type                       | `string`  | db-f1-micro   |
| deletion_protection | Enable Delete Protection            | `bool`    | true          |

### Notes

