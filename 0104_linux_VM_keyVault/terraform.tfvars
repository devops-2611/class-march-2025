varrg = {
  vm01 = {
    rg-name                       = "welcomerg-1"
    location                      = "west US"
    vnet-name                     = "welcome-vnet1"
    address_space                 = ["10.1.0.0/16"]
    subnet-name                   = "welcome-snet1"
    address_prefixes              = ["10.1.0.0/24"]
    pip-name                      = "welcomepip1"
    allocation_method             = "Static"
    ni-name                       = "welcomeni1"
    ip-name                       = "welcomeip1"
    private_ip_address_allocation = "Dynamic"
    vm-name                       = "welcomevm1"
    size                          = "Standard_F2"
    nsg-name                      = "welcomensg1"
    security-name                 = "welcomesec1"
    key-vault-name                = "welcome-key1"
    kv-rg-name                    = "NetworkWatcherRG"
    user-secret-name              = "username"
    password-secret-name          = "password"
  }


    vm02 = {
    rg-name                       = "welcomerg-2"
    location                      = "west US"
    vnet-name                     = "welcome-vnet2"
    address_space                 = ["10.1.0.0/16"]
    subnet-name                   = "welcome-snet1"
    address_prefixes              = ["10.1.0.0/24"]
    pip-name                      = "welcomepip2"
    allocation_method             = "Static"
    ni-name                       = "welcomeni2"
    ip-name                       = "welcomeip2"
    private_ip_address_allocation = "Dynamic"
    vm-name                       = "welcomevm2"
    size                          = "Standard_F2"
    nsg-name                      = "welcomensg2"
    security-name                 = "welcomesec2"
    key-vault-name                = "welcome-key2"
    kv-rg-name                    = "NetworkWatcherRG"
    user-secret-name              = "username"
    password-secret-name          = "password"
  }



}