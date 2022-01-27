terraform {
  backend "azurerm" {
    resource_group_name  = "Moonshot_Terraform_Backend"
    storage_account_name = "moonshottfbackend"
    container_name       = "common-moonshot-infrastructure-state"
    key                  = "dev/moonshotfunc2/terraform.tfstate"
  }
}
