varrg = {
  vm01 = {
    rg-name                       = "FE-RG"
    location                      = "North Europe"
    vnet-name                     = "welcome-vnet1"
    address_space                 = ["10.1.0.0/16"]
    subnet-name                   = "welcome-snet1"
    address_prefixes              = ["10.1.0.0/24"]
    pip-name                      = "welcomepip1"
    allocation_method             = "Static"
    ni-name                       = "welcomeni1"
    ip-name                       = "welcomeip1"
    private_ip_address_allocation = "Dynamic"
    vm-name                       = "FE"
    size                          = "Standard_F2"
    admin_username                = "welcomeuser"
    admin_password                = "welcome@12345"
    nsg-name                      = "welcomensg1"
    security-name                 = "welcomesec1"
  }

  vm02 = {
    rg-name                       = "BE-RG"
    location                      = "UK South"
    vnet-name                     = "welcome-vnet2"
    address_space                 = ["10.2.0.0/16"]
    subnet-name                   = "welcome-snet1"
    address_prefixes              = ["10.2.0.0/24"]
    pip-name                      = "welcomepip2"
    allocation_method             = "Static"
    ni-name                       = "welcomeni2"
    ip-name                       = "welcomeip2"
    private_ip_address_allocation = "Dynamic"
    vm-name                       = "BE"
    size                          = "Standard_F2"
    admin_username                = "welcomeuser"
    admin_password                = "welcome@12345"
    nsg-name                      = "welcomensg2"
    security-name                 = "welcomesec2"
  }
  vm03 = {
    rg-name                       = "DB-RG"
    location                      = "central India"
    vnet-name                     = "welcome-vnet1"
    address_space                 = ["10.1.0.0/16"]
    subnet-name                   = "welcome-snet1"
    address_prefixes              = ["10.1.0.0/24"]
    pip-name                      = "welcomepip1"
    allocation_method             = "Static"
    ni-name                       = "welcomeni1"
    ip-name                       = "welcomeip1"
    private_ip_address_allocation = "Dynamic"
    vm-name                       = "DB"
    size                          = "Standard_F2"
    admin_username                = "welcomeuser"
    admin_password                = "welcome@12345"
    nsg-name                      = "welcomensg1"
    security-name                 = "welcomesec1"
  }

}