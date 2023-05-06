# GCP Hybrid Networking

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

| Name           | Description                        | Type     | Default |
|----------------|------------------------------------|----------|---------|
| project_id     | Project ID of the GCP project      | `string` | n/a     |


#### VPN Tunnels w/ Dynamic Routing

```
vpns = {
}
```