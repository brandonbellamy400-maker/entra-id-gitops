terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = "48f3dbef-a421-4fcb-9061-83677564f5c6"
}

provider "azuread" {
  tenant_id = "48f3dbef-a421-4fcb-9061-83677564f5c6"
}