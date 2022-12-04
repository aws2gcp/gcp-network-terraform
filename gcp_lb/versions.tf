terraform {
  required_version = ">= 1.3.2"
  required_providers {
    google = ">= 4.44.1"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
