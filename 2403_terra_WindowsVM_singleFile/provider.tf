terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "233246a7-8523-487e-9a43-d155fcd332db"
  features {}


  # Configuration options
}