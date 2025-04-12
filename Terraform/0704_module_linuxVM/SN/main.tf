variable "varsn" {}

resource "azurerm_subnet" "sapan-snet-block" {
    for_each = var.varsn
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name =each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

}