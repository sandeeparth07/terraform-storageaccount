# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
    subscription_id = "{subscription id}"
    client_id = "{client id}"
    client_secret = "{client secret}"
    tenant_id = "{tenant id}"
    features{}
}

variable "storage_account_name" {
  type = string
  description = "please enter storage account name"
  default = "storageaccount65783"
  
}

locals {
  resource_group = "app-grp"
  location = "westus2"
}

resource "azurerm_resource_group" "app_grp" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true 
  depends_on = [ azurerm_resource_group.app_grp ]

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = var.storage_account_name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "sample" {
  name = "sample.txt"
  storage_account_name = var.storage_account_name
  storage_container_name = azurerm_storage_container.data.name
  type = "Block"
  source = "sample.txt"
  depends_on = [ azurerm_storage_container.data ]
}
