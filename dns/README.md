# Google Cloud Platform DNS Zones, Records, and Policies

## Resources 

- [google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
- [google_dns_record_set](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)
- [google_dns_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_policy)

## Inputs 

### Required Inputs

| Name            | Description                        | Type     |
|-----------------|------------------------------------|----------|
| project\_id     | Project ID of the GCP project      | `string` | 

### Inputs for DNS Zones

| Name               | Description                                              | Type     | Default |
|--------------------|----------------------------------------------------------|----------|---------|
| network_name       | VPC Network Name for LB Listener                         | `string` | default |
| subnet_name        | Name of the Subnet                                       | `string` | n/a     |
| network_project_id | If using Shared VPC, Project ID of the Host              | `string` | n/a     |

#### Notes

- `network_name` is also required for Regional external HTTP(S) load balancer if VPC network is not "default"

### Usage Examples

#### Public DNS Zone

```
dns_zones = {
  public1 = {
    dns_name = "mydomain.com"
  }
}
```

#### DNS Zone for Private Google Access

```
dns_zones = {
  google-apis = {
    dns_name         = "googleapis.com."
    visible_networks = ["network1", "network2"]
    records = [
      {
        name    = "private"
        type    = "A"
        ttl     = 60
        rrdatas = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
      },
      {
        name    = "*"
        type    = "cname"
        ttl     = 300
        rrdatas = ["private.googleapis.com."]
      }
    ]
  }
}
```

#### DNS Policy

```
dns_policies = {
}
```