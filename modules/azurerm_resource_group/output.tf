output "resource_groups" {
  value = {
    for k, v in azurerm_resource_group.rg : k => {
      id       = v.id
      name     = v.name
      location = v.location
    }
  }
  description = "Map of created Resource Groups with their details"
}