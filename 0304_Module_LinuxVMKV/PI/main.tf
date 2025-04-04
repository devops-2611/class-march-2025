variable "varpi" {}

resource "azurerm_public_ip" "pip-block" {
  for_each            = var.varpi
  name                = each.value.pip-name
  resource_group_name = each.value.rg-name
  location            = each.value.location
  allocation_method   = each.value.allocation_method
}

