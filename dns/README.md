# GCP DNS Zones, Records, Server Policies, and Response Policy Zones

## Resources 

- [google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)
- [google_dns_record_set](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set)
- [google_dns_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_policy)

## Inputs 

### Global Inputs

| Name           | Description                        | Type     | Default |
|----------------|------------------------------------|----------|---------|
| project_id     | Project ID of the GCP project      | `string` | n/a     |

### Inputs for DNS Zones

DNS Zones are defined as a map of objects in the `dns_zones` variable.  Attributes are described below:

| Name                 | Description                                              | Type            | Default |
|----------------------|----------------------------------------------------------|-----------------|---------|
| project_id           | GCP Project ID for the zone                              | `string`        | n/a     |
| name                 | Name of the DNS Zone (i.e. "example")                    | `string`        | n/a     |
| description          | Description of the DNS Zone                              | `string`        | n/a     |
| dns_name             | DNS Domain Name (i.e. "example.com.")                    | `string`        | n/a     |
| visibility           | Visibility (`public` or `private`)                       | `string`        | public  |
| visibile_networks    | For private zones, list of VPC network names to apply to | `list(string)`  | []      |
| peer_project_id      | For DNS Peering, the remote Project ID                   | `string`        | n/a     |
| peer_network_name    | For DNS Peering, the remote VPC network name             | `string`        | n/a     |
| target_name_servers  | If using Shared VPC, Project ID of the Host              | `list(string)`  | []      |
| logging              | Whether to log DNS queries                               | `bool`          | false   |
| records              | List of DNS records inside this zone                     | `list(ojbect)`  | []      |

#### Notes

- If `project_id` is not specified, `var.project_id` will be used
- If `name` is not specified, they key in the map entry will be used
- If `dns_name` lacks a "." at the end, it will be automatically added


### Inputs for DNS Records

| Name    | Description                                        | Type           | Default |
|---------|----------------------------------------------------|----------------|---------|
| name    | Name of the DNS entry inside the zone (i.e. "www") | `string`       | n/a     |
| type    | Type of record (i.e. A, CNAME, PTR, etc)           | `string`       | A       |
| ttl     | DNS Max TTL Value, in seconds                      | `number`       | 300     |
| rrdatas | Data (values) for the record                       | `list(string)` | []      |

#### Notes

### Inputs for DNS Server Policies

| Name                        | Description                                               | Type           | Default  |
|-----------------------------|-----------------------------------------------------------|----------------|----------|
| project_id                  | GCP Project ID for the DNS Server Policy                  | `string`       | n/a      |
| name                        | Name of the DNS Server Policy                             | `string`       | n/a      |
| description                 | Description of the DNS Server Policy                      | `string`       | n/a      |
| enable_inbound_forwarding   | Whether to log DNS queries                                | `bool`         | true     |
| logging                     | Whether to log DNS queries                                | `bool`         | false    |
| networks                    | For private zones, list of VPC network names to apply to  | `list(string)` | []       |
| target_name_servers         | Internal Name Servers.  See structure below               | `list(object)` | []       |

### Inputs for DNS Server Policy Target Name Servers

| Name             | Description                            | Type        | Default  |
|------------------|----------------------------------------|-------------|----------|
| ipv4_address     | IPv4 Address of the DNS server         | `string`    | n/a      |
| forwarding_path  | How to handle non-RFC1918 DNS Servers  | `string`    | default  |

#### Notes

- Use `forwarding_path = "private"` to force non-RFC1918 servers to use the VPC network's route table
- Use `forwarding_path = "default"` to send non-RFC1918 server traffic via Internet

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

#### Import examples

Import existing DNS zone

```
terraform import 'google_dns_managed_zone.default[\"my-zone\"]' my-project/my-zone
```