terraform {
  backend "gcs" {
    bucket = "private-j5-org"
    prefix = "tf-state/gcp_vpc_network"
  }
}

