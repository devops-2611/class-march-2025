variable "varvm" {}

resource "azurerm_linux_virtual_machine" "example" {
    for_each = var.varvm
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      =each.value.admin_username
  admin_password = each.value.admin_password
  network_interface_ids = [data.azurerm_network_interface.sapan-data-ni-bl[each.value.ni-key].id]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}



variable "vardatanic" {}

data "azurerm_network_interface" "sapan-data-ni-bl" {
    for_each = var.vardatanic
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
