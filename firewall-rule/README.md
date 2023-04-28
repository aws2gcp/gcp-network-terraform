# Management of a Google Cloud Platform Firewall Rule

## Relevant Resources

- [google_compute_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)

## Inputs 

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| project\_id | Project id of the project that holds the network | `string` | 

### Recommend Inputs

| Name | Description | Type |
|------|-------------|------|
| network_name | Name of the network this set of firewall rules applies to | `string` |

### Optional Inputs

| Name                    | Description                                                                           | Type | Default            |
|-------------------------|---------------------------------------------------------------------------------------|------|--------------------|
| name                    | Explicit name for this resource                                                       | `string` | n/a                |
| name_prefix             | Name prefix for auto-generated name                                                   | `string` | n/a                |
| description             | Description for this resource                                                         | `string` | n/a                |
| logging                 | Whether to enable logging for rule hits                                               | `bool` | false              | 
| priority                | Priority number (lower number is higher priority)                                     | `number` | 1000               |
| direction               | Direction of trafic (ingress or egress)                                               | `string` | "INGRESS"          |
| action                  | Whether to allow or deny traffic                                                      | `string` | "ALLOW"            |
| ranges                  | IP Ranges for this rule                                                               | `list(string)` | ["169.254.169.254"] |
| range_types             | GCP IP Range Names (i.e. 'iap-forwarders')                                            | `list(string)` | n/a                |
| ports                   | List of TCP/UDP Ports (defaults to TCP only, unless protocol or protocols specified ) | `list(number)` | n/a                |
| port                    | Single TCP/UDP Port (defaults to TCP only, unless protocol or protocols specified )   | `number` | n/a                |
| protocol                | IP Protocol for this rule (tcp, udp, icmp, etc)                                       | `string` | n/a                |
| protocols               | IP Protocols for this rule (tcp, udp, icmp, etc)                                      | `list(string)` | n/a                |
| target_tags             | List of Network Tags to apply rule to                                                 | `list(string)` | n/a                |
| source_tags             | List of Network Tags to match source (ingress only)                                   | `list(string)` | n/a                |
| source_service_accounts | List of Service Account e-mails to match source                                       | `list(string)` | n/a                |
| target_service_accounts | List of Service Account e-mails to match source                                       | `list(string)` | n/a                |
| enforcement             | Whether to actually enable this rule or just log traffic                              | `bool` | true               |
| disabled                | Whether to disable this rule or enforce it  (opposite of `var.enforcement`)           | `bool` | false              |
| network                 | Simply an alias for `var.network_name`                                                | `string` | n/a                |

#### Notes

- If `name_prefix` is ommitted, it will be auto-generated
- If both `short_name` and `name` are ommited, rule name will be name_prefix + random 8-character string
- `source_tags` and `source_service_accounts` are ignored for egress rules
- `ports` (plural) will override `port` (singular)
- `protocols` (plural) will override `protocol` (singular)
- `network_name` will override `network`
- If neither `network_name` nor `network `are specified, default network name is "default"
- `enforcement=true` will override `disabled`
- For valid `range_types`, see data query [google_netblock_ip_ranges](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges)

## Outputs

| Name | Description | Type |
|------|-------------|------|
| id | Id of the firewall rule (projects/{{project}}/global/firewalls/{{name}}) | `string` |
| name | Name of the firewall rule | `string` |
| self\_link | Full URL of the resource | `string` | 
| creation\_timestamp | Date and Time the resource was created  | `string` |

### Usage Examples

#### Allow SSH and RDP from IAP IP ranges

```
name        = "allow-iap-forwarders"
range_types = ["iap-forwarders"]
ports       = [22,3389]
```

#### Allow DNS traffic to Instances with Network Tag 'dns-server'

```
name         = "allow-dns-to-dns-servers"
ports        = [53]
protocols    = ["udp","tcp"]
target_tags  = ["dns-server"]
```

#### Allow Web Servers to talk to Databases

```
name         = "allow-web-to-db"
priority     = 100
source_tags  = ["web"]
target_tags  = ["database"]
```

#### Allow ICMP from private IPs with logging enabled

```
name       = "allow-icmp-from-private-networks"
priority   = 1
ranges     = ["192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
protocol   = "icmp"
logging    = true
```

#### Allow mix of TCP and UDP traffic on different ports

```
name       = "allow-file-transfer-from-private-networks"
ranges     = ["192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
allow = [
    {
        protocol = "tcp"
        ports    = [20,21,22]
    },
    {
        protocol = "UDP"
        ports    = [69]
    }
]
```

#### Allow VPN Traffic from the Internet

```
name       = "allow-vpn-traffic-from-internet"
ranges     = ["0.0.0.0/0"]
protocols  = ["esp", "AH"]
```

#### Allow egress traffic to private IPs

```
short_name = "to-private-networks"
priority   = 65534
direction  = "egress"
ranges     = ["192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
```

#### Just log traffic to a certain service account

```
short_name              = "log-to-sa"
target_service_accounts = ["something@xyz.iam.gserviceaccount.com"]
ranges                  = ["0.0.0.0/0"]
logging                 = true
enforcement             = false
```

#### Deny egress traffic to Internet with logging enabled

```
short_name = "log-egress"
priority   = 65535
direction  = "egress"
action     = "deny"
ranges     = ["0.0.0.0/0"]
logging    = true
```
