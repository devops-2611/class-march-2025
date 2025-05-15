terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "eb207d43-84ba-47e7-9cc8-b80d01a978ef"
  features {
    # resource_group {
    #   prevent_deletion_if_contains_resources = false
    # }

  }
  # Configuration options
}
