
variable "varnsgdata" {}

resource "azurerm_network_interface_security_group_association" "nsg-asso-block" {
  for_each                  = var.varnsgdata
  network_interface_id      = data.azurerm_network_interface.data-bl-ni[each.key].id
  network_security_group_id = data.azurerm_network_security_group.data-bl-nsg[each.key].id

}

data "azurerm_network_security_group" "data-bl-nsg" {
    for_each = var.varnsgdata
  name                = each.value.name
  resource_group_name = each.value.rg-name
}

data "azurerm_network_interface" "data-bl-ni" {
    for_each = var.varnsgdata
  name                = each.value.ni-name
  resource_group_name = each.value.rg-name
}