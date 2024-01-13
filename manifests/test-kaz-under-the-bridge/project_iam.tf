locals {
  service_accounts = [
    {
      name         = "tfc-wi"
      display_name = "for Terraform Cloud via WI Federation"
    }
  ]

  role_bindings = [
    {
      //変更マシンには管理権限を
      name = "cicd-machine-account(Terraform Cloud)"
      roles = [
        "roles/editor",
        "roles/resourcemanager.projectIamAdmin",
      ]
      members = [
        "serviceAccount:tfc-wi@test-kaz-under-the-bridge.iam.gserviceaccount.com"
      ]
    },
    {
      //人には弱めの権限を(必要に応じて管理権限を狭いスコープで都度付与する)
      name = "sre"
      roles = [
        "roles/viewer",
        "roles/resourcemanager.projectIamAdmin",
      ]
      members = [
        "user:kaz@under-the-bridge.work",
      ]
    }
  ]

  // role_bindigsのreform処理
  /*
    roles_bindigsの形式を以下のような形に変換する
    + test = {
      + "roles/editor"              = [
          + "kaz@under-the-bridge.work",
        ]
      + "roles/iam.ProjectIamAdmin" = [
          + "kaz@under-the-bridge.work",
        ]
    }
  */
  role_members = flatten(
    [for b in local.role_bindings :
      [for role in b.roles : { "role" = role, "members" = b.members }]
    ]
  )

  roles = distinct(flatten(
    [for rs in local.role_bindings : rs.roles])
  )

  reformed_bindings = {
    for role in local.roles :
    role => flatten([for elm in local.role_members : elm.members if elm.role == role])
  }
}

resource "google_service_account" "main" {
  for_each = { for sa in local.service_accounts : sa.name => sa }

  account_id   = each.value.name
  display_name = each.value.display_name
}

module "project-iam-bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [data.google_client_config.current.project]
  mode     = "authoritative"

  bindings = local.reformed_bindings
}
