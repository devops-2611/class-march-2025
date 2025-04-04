varenvrg = {
  rg01 = {
    rg-name  = "sapanrg-1"
    location = "west US"
  }
}

varenvvn = {
  vn01 = {
    vnet-name     = "sapanvnet-1"
    address_space = ["10.0.0.0/16"]
    location      = "west US"
    rg-name       = "sapanrg-1"

  }

}

varenvsn = {
  sn01 = {
    subnet-name      = "sapansnet-1"
    vnet-name        = "sapanvnet-1"
    address_prefixes = ["10.0.0.0/24"]
    rg-name          = "sapanrg-1"
  }
}

varenvpi = {

  pi01 = {
    pip-name          = "sapanpip-1"
    rg-name           = "sapanrg-1"
    location          = "west US"
    allocation_method = "Static"

  }
}

varenvni = {
  ni01 = {
    ni-name                       = "sapanni-1"
    rg-name                       = "sapanrg-1"
    location                      = "west US"
    ip-name                       = "sapanip-1"
    snet-key                      = "sn01"
    pip-key                       = "pi01"
    private_ip_address_allocation = "Dynamic"
  }
}


varenvvm = {

  vm01 = {
    vm-name  = "sapanvm-1"
    rg-name  = "sapanrg-1"
    location = "west US"
    size     = "Standard_F2"
    ni       = "ni01"
    # kv       = "kv01"
    admin_username = "welcomeuser"
    admin_password = "welcome@12345"

  }
}

# varenvkv = {
#   kv01 = {
#     key-vault-name       = "welcome-key1"
#     kv-rg-name           = "NetworkWatcherRG"
#     user-secret-name     = "username"
#     password-secret-name = "password"

#   }
# }


varenvnsg = {
  nsg01={
    name = "sapannsg-1"
    location = "west US"
    rg-name  = "sapanrg-1"
  }
}

varenvninsg ={

  nsgni01 = {
    name = "sapannsg-1"
    rg-name  = "sapanrg-1"
    ni-name = "sapanni-1"
  }
}