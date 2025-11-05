locals {
  organization_level_nrn = split(":", var.account_level_nrn)[0]
  nullplatform_base_helm_version = "2.22.1"
}
