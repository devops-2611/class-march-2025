resource "azurerm_resource_group" "rg-block" {
  name     = "vm-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vn-block" {
  name                = "vm-vnet"
  location            = azurerm_resource_group.rg-block.location
  resource_group_name = azurerm_resource_group.rg-block.name
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "sn-block" {
  name                 = "vm-snet"
  resource_group_name = azurerm_resource_group.rg-block.name
  virtual_network_name = azurerm_virtual_network.vn-block.name
  address_prefixes     = ["10.0.1.0/24"]

}


resource "azurerm_public_ip" "pip-block" {
  name                = "vm-pip"
  resource_group_name = azurerm_resource_group.rg-block.name
  location            = azurerm_resource_group.rg-block.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "ni-block" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg-block.location
  resource_group_name = azurerm_resource_group.rg-block.name

  ip_configuration {
    name                          = "vm-ip"
    subnet_id                     = azurerm_subnet.sn-block.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip-block.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-block" {
    name = "vm-vm"
    resource_group_name = azurerm_resource_group.rg-block.name
    location            = azurerm_resource_group.rg-block.location
    size                = "Standard_D4s_v3"
    admin_username      = "welcomeuser"
    admin_password      = "welcome@12345"
    network_interface_ids = [azurerm_network_interface.ni-block.id]
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

resource "azurerm_network_security_group" "nsg-block" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg-block.location
  resource_group_name = azurerm_resource_group.rg-block.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface_security_group_association" "nsgni-block" {
  network_interface_id      = azurerm_network_interface.ni-block.id
  network_security_group_id = azurerm_network_security_group.nsg-block.id
}