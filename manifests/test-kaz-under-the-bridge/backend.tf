terraform {
  cloud {
    organization = "under-the-bridge"
    workspaces {
      name = "my-cloud-iac-gcp"
    }
  }
}
