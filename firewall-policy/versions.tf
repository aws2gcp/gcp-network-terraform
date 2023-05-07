terraform {
  required_version = ">= 1.3.4"
  required_providers {
    google = {
      source           = "hashicorp/google"
      required_version = "> 4.50.0"
    }
  }
}
