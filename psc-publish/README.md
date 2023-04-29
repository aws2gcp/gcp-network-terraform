# Publish GCP Service via Private Service Connect

## Resources

- [google_compute_service_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment)

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| project\_id | Project ID to publish the service in | `string` | 
| nat\_subnet\_names | Names of the subnet(s) to use on the publisher side | `list(string)` | 

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| target\_service\_id | ID of the Published Service.  Usually a forwarding rule | `string` | n/a |
| forwarding\_rule\_name | Name of the forwarding rule to publish (assumes same project) | `string` | n/a |
| name | Name to be given to the PSC published service  | `string` | n/a |
| description | Description for the service attachment | `string` | n/a |
| region | GCP Region to publish the service in | `string` | n/a |

#### Notes

- Either `target_service_id` or `forwarding_rule_name` must be provided
- If region is not specified, it is assumed to be same as the published service
- If name is not specified, it will be auto-generated: `psc-${REGION}-${SERVICE_NAME}`

## Outputs

| Name | Description | Type |
|------|-------------|------|
| self_link | URL of the Published Service | `string` |

### Usage Examples

#### Target Service ID Explicitly given

```
project_id         = "my-project-id"
target_service_id  = "projects/my-project-id/regions/us-central1/forwardingRules/my-serivce"
nat_subnet_names  = ["mynetwork-psc-subnet1"]
```

#### Region and Forwarding Rule name provided

```
project_id            = "my-project-id"
region                = "us-central1"
forwarding_rule_name  = "my-forwarding-rule"
nat_subnet_names      = ["mynetwork-psc-subnet1"]
```

