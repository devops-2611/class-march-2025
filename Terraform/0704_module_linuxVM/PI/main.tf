variable "varpi" {}
resource "azurerm_public_ip" "sapna-pip-block" {
    for_each = var.varpi
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = each.value.allocation_method
}