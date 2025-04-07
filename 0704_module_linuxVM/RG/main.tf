variable "varrg" {}

resource "azurerm_resource_group" "sapan-block" {
    for_each = var.varrg        
  name     = each.value.rgname
  location = each.value.location
}

