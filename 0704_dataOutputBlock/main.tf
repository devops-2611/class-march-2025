data "azurerm_resource_group" "sapan-block" {
  name = "sapan.rg"
}

output "id" {
  value = data.azurerm_resource_group.sapan-block.id
  
}