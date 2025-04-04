variable "varvm" {}

resource "azurerm_linux_virtual_machine" "vm-block" {
  for_each                        = var.varvm
  name                            = each.value.vm-name
  resource_group_name             = each.value.rg-name
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
#    admin_username                  = data.azurerm_key_vault_secret.username-data-secret[each.value.kv].value  # username
#   admin_password                  = data.azurerm_key_vault_secret.password-data-secret[each.value.kv].value  # password

  disable_password_authentication = false
  network_interface_ids           = [data.azurerm_network_interface.ni-data-bl[each.value.ni].id]
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

variable "vardatani" {}
data "azurerm_network_interface" "ni-data-bl" {
    for_each = var.vardatani
  name                = each.value.ni-name
  resource_group_name = each.value.rg-name
}

# variable "varkv" {}
# data "azurerm_key_vault" "key-vault-data-block" {
#   for_each            = var.varkv
#   name                = each.value.key-vault-name
#   resource_group_name = each.value.kv-rg-name
# }


# data "azurerm_key_vault_secret" "username-data-secret" {
#   for_each     = var.varkv
#   name         = each.value.user-secret-name
#   key_vault_id = data.azurerm_key_vault.key-vault-data-block[each.key].id
# }

# data "azurerm_key_vault_secret" "password-data-secret" {
#   for_each     = var.varkv
#   name         = each.value.password-secret-name
#   key_vault_id = data.azurerm_key_vault.key-vault-data-block[each.key].id
# }

