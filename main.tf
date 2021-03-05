# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.50.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable sku_tier {
  type    = string
  default = "PremiumV2"
}

variable sku_size {
  type    = string
  default = "P1v2"
}

variable site_config {
  type = map
  default = {
    always_on = true
  }
}

resource "random_id" "suffix" {
  byte_length = 5
}

resource "azurerm_resource_group" "this" {
  name     = format("rg-tfbug%s", random_id.suffix.hex)
  location = "Central US"
}

resource "azurerm_storage_account" "this" {
  name                     = format("sttfbug%s", random_id.suffix.hex)
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "this" {
  name                = format("plan-tfbug-%s", random_id.suffix.hex)
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "FunctionApp"

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

resource "azurerm_function_app" "this" {
  name                       = format("func-tfbug-%s", random_id.suffix.hex)
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  dynamic "site_config" {
    for_each = var.site_config
    content {
      always_on = site_config.value
    }
  }
}
