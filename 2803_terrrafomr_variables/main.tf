variable "sapan" {}

resource "azurerm_resource_group" "rgwel" {
  name     = var.sapan.rg-name
  location = var.sapan.rg-location
}

resource "azurerm_virtual_network" "vnwel" {
  name                = var.sapan.vnet-name
  location            = var.sapan.rg-location
  resource_group_name = var.sapan.rg-name
  address_space       = var.sapan.adress_vnet
  depends_on          = [azurerm_resource_group.rgwel]

}

resource "azurerm_subnet" "snwel" {
  name                 = var.sapan.snet-name
  resource_group_name  = var.sapan.rg-name
  virtual_network_name = var.sapan.vnet-name
  address_prefixes     = var.sapan.snet_cidr
  depends_on           = [azurerm_virtual_network.vnwel]
}

resource "azurerm_public_ip" "piwel" {
  name                = var.sapan.pip_name
  resource_group_name = var.sapan.rg-name
  location            = var.sapan.rg-location
  allocation_method   = var.sapan.alloca_method
  depends_on          = [azurerm_resource_group.rgwel]
}


resource "azurerm_network_interface" "niwel" {
  name                = var.sapan.ni-name
  resource_group_name = var.sapan.rg-name
  location            = var.sapan.rg-location
  depends_on          = [azurerm_public_ip.piwel, azurerm_resource_group.rgwel]


  ip_configuration {
    name                          = var.sapan.ip-config-name
    private_ip_address_allocation = var.sapan.private_ip_allo
    public_ip_address_id          = azurerm_public_ip.piwel.id
    subnet_id                     = azurerm_subnet.snwel.id
  }
}

resource "azurerm_linux_virtual_machine" "vmwel" {
  name                            = var.sapan.vm-name
  resource_group_name             = var.sapan.rg-name
  location                        = var.sapan.rg-location
  size                            = var.sapan.vm-size
  disable_password_authentication = false
  admin_username                  = var.sapan.vm-username
  admin_password                  = var.sapan.vm-password
  network_interface_ids           = [azurerm_network_interface.niwel.id]
  depends_on                      = [azurerm_network_interface.niwel, azurerm_resource_group.rgwel]


  os_disk {
    caching              = var.sapan.cachig
    storage_account_type = var.sapan.storage_account_type
  }
  source_image_reference {
    publisher = var.sapan.publisher
    offer     = var.sapan.offer
    sku       = var.sapan.sku
    version   = var.sapan.version
  }
}