variable "varrg" {}

resource "azurerm_resource_group" "rg-block" {
  for_each = var.varrg
  name     = each.value.rg-name
  location = each.value.location
}

resource "azurerm_virtual_network" "vnet-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.vnet-name
  address_space       = each.value.address_space
  location            = each.value.location
  resource_group_name = each.value.rg-name

}

resource "azurerm_subnet" "subnet-block" {
  for_each             = var.varrg
  depends_on           = [azurerm_virtual_network.vnet-block]
  name                 = each.value.subnet-name
  virtual_network_name = each.value.vnet-name
  address_prefixes     = each.value.address_prefixes
  resource_group_name  = each.value.rg-name
}

resource "azurerm_public_ip" "pip-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.pip-name
  resource_group_name = each.value.rg-name
  location            = each.value.location
  allocation_method   = each.value.allocation_method

}

resource "azurerm_network_interface" "ni-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_subnet.subnet-block]
  name                = each.value.ni-name
  resource_group_name = each.value.rg-name
  location            = each.value.location

  ip_configuration {
    name                          = each.value.ip-name
    subnet_id                     = azurerm_subnet.subnet-block[each.key].id
    public_ip_address_id          = azurerm_public_ip.pip-block[each.key].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
  }
}

resource "azurerm_linux_virtual_machine" "vm-block" {
  for_each                        = var.varrg
  depends_on                      = [azurerm_network_interface.ni-block]
  name                            = each.value.vm-name
  resource_group_name             = each.value.rg-name
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.ni-block[each.key].id]
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

resource "azurerm_network_security_group" "nsg-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.nsg-name
  location            = each.value.location
  resource_group_name = each.value.rg-name
}


resource "azurerm_network_security_rule" "http_rule_vm01" {
  for_each                    = var.varrg
  name                        = each.value.security-name
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = each.value.rg-name
  network_security_group_name = each.value.nsg-name
}


resource "azurerm_network_interface_security_group_association" "nsg-asso-block" {
  for_each                  = var.varrg
  network_interface_id      = azurerm_network_interface.ni-block[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg-block[each.key].id

}


