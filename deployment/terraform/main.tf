terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

#############################################
### Checking existence of resource
/*
data "local_file" "is_rg_exist" {
  filename = "${var.project}-${var.environment}-resource-group.tmp"
  depends_on = [module.existing_resource]
}


module "existing_resource" {
  source = "./modules/azurerm_exist"
  ResName = "${var.project}-${var.environment}-resource-group.tmp"
}

*/
#############################################



resource "azurerm_resource_group" "rg" {
  #count = filebase64sha256("state.tfstate") == "" ? 1 : 0
  name = "${var.project}-${var.environment}-resource-group"
  location = var.location
  #
}

resource "azurerm_storage_account" "storage_account" {
  name = "${var.project}${var.environment}storage"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  depends_on = [azurerm_resource_group.rg]
}



resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-${var.environment}-application-insights-test"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  depends_on = [azurerm_resource_group.rg]
}

/*
resource "azurerm_storage_container" "deployments" {
    name = "function-releases"
    storage_account_name = "${azurerm_storage_account.storage_account.name}"
    container_access_type = "private"
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "function-app.zip"
}

resource "azurerm_storage_blob" "appcode" {
    name = "functionapp.zip"
    storage_account_name = "${azurerm_storage_account.storage_account.name}"
    storage_container_name = "${azurerm_storage_container.deployments.name}"
    type = "Block"
    source = var.functionapp
}
*/

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  kind     = "FunctionApp"
  reserved = false
  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id

  os_type 		     = "linux"

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet"
  }
  depends_on = [azurerm_resource_group.rg]
}
