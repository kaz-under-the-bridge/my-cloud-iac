locals {
  tfc_organization_name = "under-the-bridge"
  tfc_project_name      = "myGCP"
  tfc_workspace_name    = "my-cloud-iac-gcp"
}

resource "google_iam_workload_identity_pool" "tfc_pool" {
  workload_identity_pool_id = "my-tfc-pool"
}

resource "google_iam_workload_identity_pool_provider" "tfc_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "my-tfc-provider-id"

  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
  oidc {
    issuer_uri = "https://app.terraform.io"
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${local.tfc_organization_name}:project:${local.tfc_project_name}:workspace:${local.tfc_workspace_name}\")"
}

resource "google_service_account_iam_member" "tfc_service_account_member" {
  // state名で間接的に呼び出すと、state名変更時にWI Federation連携ができなくなる（変更しているTFCの権限が失われる）可能性があるため、SA指定はベタがきにしておく
  service_account_id = "projects/test-kaz-under-the-bridge/serviceAccounts/tfc-wi@test-kaz-under-the-bridge.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc_pool.name}/*"
}
