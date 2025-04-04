variable "varvn" {}

resource "azurerm_virtual_network" "vnet-block" {
  for_each            = var.varvn
  name                = each.value.vnet-name
  address_space       = each.value.address_space
  location            = each.value.location
  resource_group_name = each.value.rg-name

}