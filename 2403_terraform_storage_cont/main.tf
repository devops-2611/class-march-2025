resource "azurerm_resource_group" "block-rg" {
  name     = "applerg"
  location = "central india"
}

resource "azurerm_storage_account" "block-storage1" {
  name                     = "applestorage11"
  resource_group_name      = azurerm_resource_group.block-rg.name
  location                 = azurerm_resource_group.block-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "block-container1" {
  name                  = "apple-container1"
  storage_account_id    = azurerm_storage_account.block-storage1.id
  container_access_type = "private"
}


resource "azurerm_storage_container" "block-container11" {
  name                  = "apple-container11"
  storage_account_id    = azurerm_storage_account.block-storage1.id
  container_access_type = "private"
}


resource "azurerm_storage_container" "block-container12" {
  name                  = "apple-container12"
  storage_account_id    = azurerm_storage_account.block-storage1.id
  container_access_type = "private"
}



resource "azurerm_storage_account" "block-storage2" {
  name                     = "applestorage12"
  resource_group_name      = azurerm_resource_group.block-rg.name
  location                 = azurerm_resource_group.block-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "block-container2" {
  name                  = "apple-container2"
  storage_account_id    = azurerm_storage_account.block-storage2.id
  container_access_type = "private"
}