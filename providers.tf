terraform {
  required_providers {
    bigcommerce = {
      source = "ashsmith/bigcommerce"
      version = "0.0.4"
    }
  }
}

provider "google" {
  region = "europe-west2"
}

provider "bigcommerce" {
}