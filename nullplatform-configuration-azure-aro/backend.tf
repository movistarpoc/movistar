terraform {
  backend "azurerm" {
    subscription_id = ""
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = "terraform.tfstate"
    # subscription_id and key must be provided via backend-config
    # Example: terraform init -backend-config="subscription_id=<your-sub-id>" -backend-config="key=movistar/terraform.tfstate"
  }
}