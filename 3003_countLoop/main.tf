resource "azurerm_resource_group" "block-rg" {
    count = 2
  name     = "applerg-${count.index+1}"  # applerg-1, applerg-2
  location = "central india"
}

# resource "azurerm_storage_account" "block-storage1" {
#     count = 2
#   name                     = "applestorage${count.index+1}"  
#   resource_group_name      = azurerm_resource_group.block-rg[count.index].name  
#   location                 = azurerm_resource_group.block-rg[count.index].location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

resource "azurerm_virtual_network" "vnwel" {
  count = 2
  name                = "apple-vn${count.index+1}"  # apple-vn1, apple-vn2
  location            = azurerm_resource_group.block-rg[count.index].location
  resource_group_name = azurerm_resource_group.block-rg[count.index].name
  address_space       = ["10.${count.index}.0.0/24"]  # ["10.0.0.0/24"], ["10.1.0.0/24"]

}


resource "azurerm_subnet" "snwel" {
  count = 2
  name                 = "apple-sn${count.index+1}" # apple-sn1, apple-sn2
  resource_group_name  = azurerm_resource_group.block-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnwel[count.index].name
  address_prefixes     = ["10.${count.index}.0.0/28"] # 10.0.0.0/28 , 10.1.0.0/28
}


resource "azurerm_network_interface" "niwel" {
  count = 2
  name                = "apple-ni${count.index+1}"
  resource_group_name = azurerm_resource_group.block-rg[count.index].name
  location            = azurerm_resource_group.block-rg[count.index].location

  
  ip_configuration {
    name                          = "apple-ip${count.index+1}"
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.piwel.id
    subnet_id                     = azurerm_subnet.snwel[count.index].id
  }
}



resource "azurerm_linux_virtual_machine" "vmwel" {
  count = 2
  name                            = "apple-vm${count.index+1}"
  resource_group_name             = azurerm_resource_group.block-rg[count.index].name
  location                        = azurerm_resource_group.block-rg[count.index].location
  size                            = "Standard_F2"
  # size                            = "Standard_D4s_v3"
  disable_password_authentication = false
  admin_username                  = "welcomeuser"
  admin_password                  = "welcome@12345"
  network_interface_ids           = [azurerm_network_interface.niwel[count.index].id]
  # depends_on                      = [azurerm_network_interface.niwel]

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
