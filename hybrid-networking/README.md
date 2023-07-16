# GCP Hybrid Networking

Management of Cloud Routers, Interconnects, and VPNs

## Resources 

- [google_compute_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router)
- [google_compute_router_interface](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface)
- [google_compute_router_peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer)
- [google_compute_interconnect_attachment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_interconnect_attachment)
- [google_compute_ha_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway)
- [google_compute_external_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway)
- [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)

## Inputs 

### Global Inputs

| Name           | Description                      | Type     | Default  |
|----------------|----------------------------------|----------|----------|
| project_id     | Project ID of the GCP project    | `string` | n/a      |
| region         | Name of the default GCP region   | `string` | n/a      |
| network_name   | Name of default VPC Network      | `string` | default  |

### Cloud Routers

The `cloud_routers` variable is a list of objects.  Attributes are below.

| Name                   | Description                         | Type      | Default            |
|------------------------|-------------------------------------|-----------|--------------------|
| name                   | Name of the Cloud Router            | `string`  | rtr-<network_name> |
| description            | Description of the Cloud Router     | `string`  | n/a                |
| project_id             | Project ID of the GCP project       | `string`  | n/a                |
| region                 | Name of the GCP region              | `string`  | n/a                |
| network_name           | Name of default VPC Network         | `string`  | default            |
| bgp_asn                | BGP AS Number for the Cloud Router  | `number`  | 64512              |
| bgp_keepalive_interval | BGP Keepalive Interval (in seconds) | `number`  | 20                 |
| create                 | Whether to create the resource      | `bool`    | true               |


#### 

The `advertised_ip_ranges` attribute is a list of objects.  Attributes are below.

| Name        | Description              | Type     | Default    |
|-------------|--------------------------|----------|------------|
| range       | IP Range to Advertise    | `string` | n/a        |
| description | Description of IP Range  | `string` | n/a        |


### Cloud VPN Gateways

The `cloud_vpn_gateways` variable is a list of objects.  Attributes are below.

| Name                   | Description                    | Type     | Default            |
|------------------------|--------------------------------|----------|--------------------|
| name                   | Name of the Cloud VPN Gateway  | `string` | rtr-<network_name> |
| region                 | Name of the GCP region         | `string` | n/a                |
| project_id             | Project ID of the GCP project  | `string` | n/a                |
| network_name           | Name of attached VPC Network   | `string` | default            |
| create                 | Whether to create the resource | `bool`   | true               |

### Peer (External) VPN Gateways

The `peer_vpn_gateways` variable is a list of objects.  Attributes are below.

| Name         | Description                             | Type            | Default              |
|--------------|-----------------------------------------|-----------------|----------------------|
| name         | Name of the Peer (External) VPN Gateway | `string`        | vpngw-<network_name> |
| description  | Description of the VPN Gateway          | `string`        | n/a                  |
| project_id   | Project ID of the GCP project           | `string`        | n/a                  |
| ip_addresses | IP Addresses for the Peer VPN Gateway   | `list(string)`  | n/a                  |
| labels       | Labels for the Peer VPN Gateway         | `map(string)`   | n/a                  |
| create       | Whether to create the resource          | `bool`          | true                 |


### VPN Tunnels

The `vpns` variable is a list of objects.  Attributes are below.

| Name                              | Description                                             | Type           | Default            |
|-----------------------------------|---------------------------------------------------------|----------------|--------------------|
| name                              | Name of the Peer (External) VPN Gateway                 | `string`       | vpn-<network_name> |
| description                       | Description of the VPN Gateway                          | `string`       | n/a                |
| project_id                        | Project ID of the GCP project                           | `string`       | n/a                |
| region                            | Name of the GCP region                                  | `string`       | n/a                |
| cloud_router                      | Name of the Cloud Router                                | `string`       | n/a                |
| cloud_vpn_gateway                 | Name of the Cloud VPN Gateway                           | `string`       | n/a                |
| peer_vpn_gateway                  | Name of the Peer VPN Gateway                            | `string`       | n/a                |
| peer_gcp_vpn_gateway_project_id   | For GCP VPN Peers, project ID of peer VPN Gatewaay      | `string`       | n/a                |
| peer_gcp_vpn_gateway              | For GCP VPN Peers, Name of the of peer VPN Gateway      | `string`       | n/a                |
| peer_bgp_asn                      | BGP AS Number for the Peer                              | `number`       | 65000              |
| advertised_priority               | Priority (BGP MED) for advertised routes                | `number`       | 100                |
| advertised_groups                 | Types of Groups to Advertise via BGP                    | `list(string)` | n/a                |
| tunnels | 

### VPN Tunnels

The `tunnels` attribute is a list of objects.  Attributes are below.

| Name                | Description                              | Type        | Default  |
|---------------------|------------------------------------------|-------------|----------|
| name                | Name of the VPN Tunnel                   | `string`    | n/a      |
| ike_version         | IKE version to use                       | `number`    | 2        |
| ike_psk             | Pre-shared Secret for IKE                | `string`    | n/a      |
| cloud_router_ip     | IP Address for the GCP end               | `string`    | n/a      |
| peer_bgp_ip         | IP address for the remote peer           | `string`    | n/a      |
| peer_bgp_asn        | BGP AS Number for the Peer               | `number`    | 65000    |
| advertised_priority | Priority (BGP MED) for advertised routes | `number`    | 100      |
| enable_bfd          | Enable the BFD failure detection         | `bool`      | false    |
| enable              | Enable the BGP session                   | `bool`      | true     |

### Interconnects

The `interconnects` variable is a list of objects.  Attributes are below.

| Name              | Description                     | Type     | Default |
|-------------------|---------------------------------|----------|---------|
| name              | Name of the Interconnect        | `string` | n/a     |
| description       | Description of the Interconnect | `string` | n/a     |
| project_id        | Project ID of the GCP project   | `string` | n/a     |
| region            | Name of the GCP region          | `string` | n/a     |
| cloud_router      | Name of the Cloud Router        | `string` | n/a     |


## Examples

### VPN Tunnels w/ Dynamic Routing

```
vpns = [
]
```

#### 2x2 VPN Tunnels from GCP to AWS

```
peer_vpn_gateways = [
  {
    name = "aws-us-east1"
    ip_addresses = [
      "3.221.123.12",    # GCP HA VPN Gateway interface 0, AWS Tunnel 1
      "52.202.123.34",   # GCP HA VPN Gateway interface 0, AWS Tunnel 2
      "18.234.123.56",   # GCP HA VPN Gateway interface 1, AWS Tunnel 1
      "52.71.123.78",    # GCP HA VPN Gateway interface 1, AWS Tunnel 2
    ]
  },
]
vpns = [
  {
    name                 = "gcp-2-aws"
    region               = "us-east4"
    cloud_router         = "my-cloud-router"
    cloud_vpn_gateway    = "my-vpn-gateway"
    peer_vpn_gateway     = "aws-us-east1"
    peer_bgp_asn         = 64512
    advertised_ip_ranges = [{ range = "10.20.30.0/23" }]
    tunnels = [
      {
        interface_index     = 0
        ike_psk             = "aaaaaaaaaaaaaa"
        cloud_router_ip     = "169.254.21.2/30"
        bgp_peer_ip         = "169.254.21.1"
        advertised_priority = 100
      },
      {
        interface_index     = 0
        ike_psk             = "bbbbbbbbbbbbbbb"
        cloud_router_ip     = "169.254.22.66/30"
        bgp_peer_ip         = "169.254.22.65"
        advertised_priority = 102
      },
      {
        interface_index     = 1
        ike_psk             = "cccccccccccccccc"
        cloud_router_ip     = "169.254.23.130/30"
        bgp_peer_ip         = "169.254.23.129"
        advertised_priority = 101
      },
      {
        interface_index     = 1
        ike_psk             = "dddddddddddddddd"
        cloud_router_ip     = "169.254.24.194/30"
        bgp_peer_ip         = "169.254.24.193"
        advertised_priority = 103
      },
    ]
  },
]
```