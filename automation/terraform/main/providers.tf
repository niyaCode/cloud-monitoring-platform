terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  subscription_id = local.subscription_id
  client_id       = var.tfspn_client_id
  client_secret   = var.tfspn_client_secret
  tenant_id       = var.azure_tenant_id
  skip_provider_registration = "true"  
}