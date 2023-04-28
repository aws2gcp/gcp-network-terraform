# Management of a Google Cloud Platform VPC Peering Connection

## Relevant Resources

- [google_compute_network_peering](https://registry.terraform.io/providers/hashicorp/google/2.20.3/docs/resources/compute_network_peering)

## Inputs 

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| project\_id | GCP Project ID for our side of the peering connection | `string` | 
| peer\_network\_name | Name of the network on the peer side of the peering connection | `string` |

### Recommend Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| peer\_project\_id | GCP Project ID for peer of the peering connection | `string` | `var.project_id` | 
| our\_network\_name | Name of the network on our side of the peering connection | `string` | "default" |

### Optional Inputs

| Name | Description                                                                       | Type | Default |
|------|-----------------------------------------------------------------------------------|------|---------|
| import_custom_routes | Whether to import static and dynamic routes from the peer network | `bool` | false |
| export_custom_routes | Whether to export static and dynamic routes to the peer network   | `bool` | false |
| enabled | Whether to actually create the peering connection | `bool` | true |

#### Notes

- If `peer_project_id` is not specified, the peer network is assumed to be in `project_id`
- If both networks are in `project_id`, the peer side will be automatically brought up

## Outputs

| Name | Description | Type |
|------|-------------|------|
| name | Local name of the VPC peering connection | `string` |
| state | State of the VPC Peering connection | `string` | 
| state\_details | Details about the state of the connection | `string` |

### Usage Examples

#### Peering two VPC networks within same project

```
project_id         = "my-project-id"
local_network_name = "abc"
peer_network_name  = "xyz"
```

#### Peering to a VPC network in a different project w/ export of custom routes enabled

```
project_id            = "my-project-id"
peer_project_id       = "buddy-project-id"
local_network_name    = "abc"
peer_network_name     = "xyz"
export_custom_routes  = true
```
