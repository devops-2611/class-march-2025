resource "azurerm_resource_group" "rgwel" {
  name     = "welcome-rg"
  location = "west us"
}

resource "azurerm_virtual_network" "vnwel" {
  name                = "welcomevn"
  location            = "west us"
  resource_group_name = azurerm_resource_group.rgwel.name
  address_space       = ["10.1.0.0/16"]
  # depends_on          = [azurerm_resource_group.rgwel]
}

resource "azurerm_subnet" "snwel" {
  name                 = "welcomesn"
  resource_group_name  = azurerm_resource_group.rgwel.name
  virtual_network_name = azurerm_virtual_network.vnwel.name
  address_prefixes     = ["10.1.0.0/28"]
  # depends_on           = [azurerm_virtual_network.vnwel]
}

resource "azurerm_public_ip" "piwel" {
  name                = "welcomeip"
  resource_group_name = azurerm_resource_group.rgwel.name
  location            = "west us"
  allocation_method   = "Static"
  # depends_on          = [azurerm_subnet.snwel]
}

resource "azurerm_network_interface" "niwel" {
  name                = "welcomenic"
  resource_group_name = azurerm_resource_group.rgwel.name
  location            = "west us"
  # depends_on          = [azurerm_public_ip.piwel, azurerm_subnet.snwel, azurerm_resource_group.rgwel]
  
  ip_configuration {
    name                          = "welcomeipc"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.piwel.id
    subnet_id                     = azurerm_subnet.snwel.id
  }
}

resource "azurerm_network_security_group" "nsgwel" {
  name                = "nsg_welcome"
  location            = "west us"
  resource_group_name = azurerm_resource_group.rgwel.name
  # depends_on          = [azurerm_resource_group.rgwel]
}

resource "azurerm_network_security_rule" "http_rule_vm01" {
  name                        = "allow-http-3000-vm01"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rgwel.name
  network_security_group_name = azurerm_network_security_group.nsgwel.name
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.niwel.id
  network_security_group_id = azurerm_network_security_group.nsgwel.id
  # depends_on                = [azurerm_resource_group.rgwel, azurerm_network_interface.niwel]
}

resource "azurerm_windows_virtual_machine" "vmwel" {
  name                            = "welcomevm"
  resource_group_name             = azurerm_resource_group.rgwel.name
  location                        = "west us"
  # size                            = "Standard_F2"
  size                            = "Standard_D4s_v3"
  # disable_password_authentication = false
  admin_username                  = "welcomeuser"
  admin_password                  = "welcome@12345"
  network_interface_ids           = [azurerm_network_interface.niwel.id]
  # depends_on                      = [azurerm_network_interface.niwel]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "19h1-pro-gensecond"
    version   = "18362.1198.2011031735"
  }
}
