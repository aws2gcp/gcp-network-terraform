terraform {
  backend "gcs" {
    bucket  = "private-j5-org"
    prefix  = "terraform"
  }
}

