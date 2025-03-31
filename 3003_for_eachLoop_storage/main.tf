variable "sapan-var" {}



resource "azurerm_resource_group" "block-rg" {
  for_each = var.sapan-var

  name     = each.value.rg-name     # sapan-rg vishal-rg
  location = each.value.rg-location # west us east us
}

resource "azurerm_storage_account" "block-storage1" {
  depends_on = [ azurerm_resource_group.block-rg ]
    for_each = var.sapan-var
  name                     = each.value.storage-name
  resource_group_name      = each.value.rg-name
  location                 = each.value.rg-location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


