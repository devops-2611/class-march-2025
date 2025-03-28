sapan = {
  rg-name                 = "sapan1-rg"
  rg-location             = "West us"
  vnet-name               = "welcomevn1"
  adress_vnet             = ["10.0.0.0/24"]
  snet-name               = "welcomesn1"
  snet_cidr               = ["10.0.0.0/28"]
  pip_name                = "welcomeip1"
  alloca_method           = "Static"
  ni-name                 = "welcomeNI1"
  ip-config-name          = "welIP1"
  private_ip_allo         = "Dynamic"
  vm-name                 = "welcomevm1"
  vm-size                 = "Standard_D4s_v3"
  vm-username             = "welcomeuser"
  vm-password             = "welcome@12345"
  offer                   = "0001-com-ubuntu-server-jammy"
  cachig                  = "ReadWrite"
  storage_account_type    = "Standard_LRS"
  publisher               = "Canonical"
  sku                     = "22_04-lts"
  version                 = "latest"


}


