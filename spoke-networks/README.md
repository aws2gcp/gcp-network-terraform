# Creation and Management of EMS single-region VPC Networks

- Subnets, Secondary Ranges
- IP Ranges and Private Service Access Connections (Netapp, etc)
- Cloud Routers & Cloud NATs
- VPC Peering
- Static Routes

# Inputs 


| Name         | Description                        | Type     | Default |
|--------------|------------------------------------|----------|--|
| project\_id  | Project ID of the GCP project      | `string` | n/a |
| name_prefix |        | `string` | n/a |
| region | GCP Region Name       | `string` | n/a |
| main_cidrs | | `list(string)` | [] |
| main_cidrs | | `list(string)` | [] |
| main_cidrs | | `list(string)` | [] |
| attached_projects | | `list(string)` | [] |
| shared_accounts | | `list(string)` | [] |
| proxy_only_cidr | | `string` | n/a |
| proxy_only_purpose | | `string` | n/a |
| servicenetworking_cidr | | `string` | 100.64.0.0/21 |
| netapp_cidr | | `string` | 10.1.0/21 |
| cloud_router_bgp_asn | BGP AS Number for Cloud Router | `number` | 64512 |
| cloud_nat_num_static_ips | Number of Static IPs for Cloud NAT | `number` | 1 |
| cloud_nat_num_min_ports_per_vm | Min number of ports to allocate for each VM | `number` | 128 |
| cloud_nat_num_max_ports_per_vm | Max number of ports to allocate for each VM | `number` | 4096 |

# Examples

```
region             = "us-west4"
main_cidrs         = ["10.214.128.0/23"]
gke_pods_cidrs     = ["100.66.0.0/16"]
gke_services_cidrs = ["100.67.0.0/17"]
attached_projects = [
  "otc-ems-fdx1",
]
shared_accounts = [
  "serviceAccount:service-620385009846@container-engine-robot.iam.gserviceaccount.com",
  "serviceAccount:service-77778400620@container-engine-robot.iam.gserviceaccount.com",
]
proxy_only_cidr        = "100.64.240.0/26"
servicenetworking_cidr = "100.64.8.0/21"
netapp_cidr            = "10.1.8.0/21"
```
