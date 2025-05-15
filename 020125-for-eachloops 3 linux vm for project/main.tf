variable "varrg" {}


resource "azurerm_resource_group" "rg-block" {
  for_each = var.varrg
  name     = each.value.rg-name
  location = each.value.rg-location
}
resource "azurerm_virtual_network" "vnet-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.vnet-name
  address_space       = each.value.vnet-cidr
  location            = each.value.rg-location
  resource_group_name = each.value.rg-name
}
resource "azurerm_subnet" "subnet-block" {
  for_each             = var.varrg
  depends_on           = [azurerm_virtual_network.vnet-block]
  name                 = each.value.subnet-name
  resource_group_name  = each.value.rg-name
  virtual_network_name = each.value.vnet-name
  address_prefixes     = each.value.subnet-cidr
}
resource "azurerm_public_ip" "pip-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.public-ip-name
  resource_group_name = each.value.rg-name
  location            = each.value.rg-location
  allocation_method   = each.value.allocation-method
}
resource "azurerm_network_interface" "ni-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_subnet.subnet-block]
  name                = each.value.ni-name
  location            = each.value.rg-location
  resource_group_name = each.value.rg-name

  ip_configuration {
    name                          = each.value.ip-name
    subnet_id                     = azurerm_subnet.subnet-block[each.key].id
    private_ip_address_allocation = each.value.ip-type
    public_ip_address_id          = azurerm_public_ip.pip-block[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "vm-blcok" {
  for_each   = var.varrg
  depends_on = [azurerm_network_interface.ni-block]

  name                            = each.value.vm-name
  resource_group_name             = each.value.rg-name
  location                        = each.value.rg-location
  size                            = each.value.vm-size
  admin_username                  = each.value.user-name  
  admin_password                  = each.value.password
  network_interface_ids           = [azurerm_network_interface.ni-block[each.key].id]
  disable_password_authentication = false


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

#nsg for vm to connect using ports
resource "azurerm_network_security_group" "nsg-block" {
  for_each            = var.varrg
  depends_on          = [azurerm_resource_group.rg-block]
  name                = each.value.nsg-name
  location            = each.value.rg-location
  resource_group_name = each.value.rg-name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with NIC 
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  for_each = var.varrg
  network_interface_id      = azurerm_network_interface.ni-block[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg-block[each.key].id
}

