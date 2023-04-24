# Google Cloud Platform Managed Instance Group w/ Auto-Scaling Support 

## Resources 

- [google_compute_instance_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_template)
- [google_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member)
- [google_compute_region_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager)
- [google_compute_region_autoscaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler)

## Inputs 

### Required Inputs

| Name        | Description                                         | Type      |
|-------------|-----------------------------------------------------|-----------|
| project_id  | Project ID of the GCP project                       | `string`  | 
| region      | GCP Region name for the instances                   | `string`  |
| name_prefix | Name prefix to give the instance template and group | `string`  |

### Optional Inputs

| Name                          | Description                                                      | Type           | Default                 |
|-------------------------------|------------------------------------------------------------------|----------------|-------------------------|
| base_instance_name            | Name prefix to give the instances                                | `string`       | n/a                     |
| description                   | Description for the instance group                               | `string`       | n/a                     |
| network_name                  | Name of the VPC network for instances                            | `string`       | default                 |
| subnet_name                   | Name of the subnetwork for the instances                         | `string`       | default                 |
| network_project_id            | If using Shared VPC, the host project ID                         | `string`       | n/a                     |
| healthcheck_ids               | Ids of the healthcheck to use for the template and MIG           | `list(string)` | n/a                     |
| healthcheck_name              | Name of the healthcheck to use instead of IDs                    | `string`       | n/a                     |
| machine_type                  | GCP Instance Machine Type                                        | `string`       | e2-small                |
| image                         | Google Image for the instances                                   | `string`       | debian-cloud/debian-11  |
| os_project                    | OS project to locate the image                                   | `string`       | debian-cloud            |
| os                            | OS name to use within os_project                                 | `string`       | debian-11               |
| disk_type                     | Disk Type for the instances                                      | `string`       | pd-standard             |
| disk_size                     | Disk Size (in GB) for the instances                              | `number`       | 20                      |
| disk_auto_delete              | Whether to delete the disk along with the instance               | `bool`         | true                    |
| target_size                   | Number of instances to launch and maintain                       | `number`       | 2                       | 
| update_type                   | When updating instances, the method to use                       | `string`       | OPPORTUNISTIC           |
| update_minimal_action         | When updating instances, the minimal action to take              | `string`       | RESTART                 |
| update_most_disruptive_action | When updating instances, the most disruptive action to perform   | `string`       | REPLACE                 |
| update_replacement_method     | When updating instances, substitute existing or replace with new | `string`       | SUBSTITUTE              |

#### Notes

- If omitted, `base_instance_name` will be the same as `name_prefix` 
- `image` will supersede `os-family` and `os`
- `target_size` is ignored if auto-scaling is enabled

### Auto-Scaling Inputs

| Name                  | Description                                                      | Type            | Default  |
|-----------------------|------------------------------------------------------------------|-----------------|----------|
| autoscaling_mode      | Whether to enable auto-scaling                                   | `string`        | OFF      |
| min_replicas          | For auto-scaling, the minimum instances to have running          | `number`        | 1        |
| max_replicas          | For auto-scaling, the maximum instances to have running          | `number`        | 10       |
| cool_down_period      | Time delay (in seconds) from launch to actively health checking  | `number`        | 60       | 
| cpu_target            | The target CPU load load to reach (1.0 = 100%)                   | `number`        | 0.6      |
| cpu_predictive_method | Name prefix to give the instances                                | `string`        | NONE     |

#### Notes

- Auto-scaling will be auto-enabled if `min_replicas` or `max_replicas` is not null

## Outputs

| Name      | Description                     | Type            |
|-----------|---------------------------------|-----------------|
| id        | ID of the Instance Group        | `string`        |
| name      | Name of the Instance Group      | `string`        |
| self_link | Self Link of the Instance Group | `string`        |

