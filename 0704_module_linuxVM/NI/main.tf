variable "varni" {}


resource "azurerm_network_interface" "example" {
    for_each = var.varni
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  ip_configuration {
    name                          = each.value.ip-name
    subnet_id                     = data.azurerm_subnet.sapan-sn-data-bl[each.value.subent-key].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id = data.azurerm_public_ip.sapan-pip-data-bl[each.value.public-key].id
  }
}

variable "vardatasn" {}

data "azurerm_subnet" "sapan-sn-data-bl" {
    for_each = var.vardatasn
  name                 = each.value.name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

variable "vardatapi" {}


data "azurerm_public_ip" "sapan-pip-data-bl" {
    for_each = var.vardatapi
  name                = each.value.name
  resource_group_name = each.value.resource_group_name 
}
