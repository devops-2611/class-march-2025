variable "varni" {}



resource "azurerm_network_interface" "ni-block" {
  for_each            = var.varni
  name                = each.value.ni-name
  resource_group_name = each.value.rg-name
  location            = each.value.location

  ip_configuration {
    name                          = each.value.ip-name
    subnet_id                     = data.azurerm_subnet.snet-dat-bl[each.value.snet-key].id  # sn01
    public_ip_address_id          = data.azurerm_public_ip.pip-dat-bl[each.value.pip-key].id # pi01
    private_ip_address_allocation = each.value.private_ip_address_allocation
  }
}

variable "vardatasn" {}

data "azurerm_subnet" "snet-dat-bl" {
    for_each = var.vardatasn
  name                 = each.value.subnet-name
  virtual_network_name = each.value.vnet-name
  resource_group_name  = each.value.rg-name
}

variable "vardatapi" {}

data "azurerm_public_ip" "pip-dat-bl" {
    for_each = var.vardatapi
  name                = each.value.pip-name
  resource_group_name = each.value.rg-name
}
