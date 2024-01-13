terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.84.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.84.0"
    }
  }
}

provider "google" {
  project = "test-kaz-under-the-bridge"
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = "test-kaz-under-the-bridge"
  region  = "asia-northeast1"

}
