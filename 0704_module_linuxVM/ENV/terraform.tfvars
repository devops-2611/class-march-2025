varenvrg = {
  rg01 = {
    rgname   = "rg01"
    location = "eastus"
  }
}

varenvvn = {
  vn01 = {
    name                = "vn01"
    location            = "eastus"
    resource_group_name = "rg01"
    address_space       = ["10.0.0.0/16"]
  }
}


varenvsn = {
  sn01 = {
    name                 = "sn01"
    resource_group_name  = "rg01"
    virtual_network_name = "vn01"
    address_prefixes     = ["10.0..0.0/24"]
  }
}




varenvpi = {
  pi01 = {
    name                = "pi01"
    resource_group_name = "rg01"
    location            = "eastus"
    allocation_method   = "Static"
  }
}


varenvni = {
  ni01 = {
    name                = "ni01"
    location            = "eastus"
    resource_group_name = "rg01"
    subent-key = "sn01"
    public-key = "pi01"
    ip-name= "ip01"
    private_ip_address_allocation = "Dynamic"
  }
}


varenvvm ={
    vm01 = {
        name                = "vm01"
        resource_group_name = "rg01"
        location            = "eastus"
        size                = "Standard_F2"
        admin_username      = "welcomeuser"
        admin_password      = "welcome@12345"
        ni-key = "ni01"
    }
}