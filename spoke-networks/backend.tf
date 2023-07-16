terraform {
  backend "gcs" {
    bucket = "otc-network-tf"
    prefix = "spoke-networks"
  }
}
