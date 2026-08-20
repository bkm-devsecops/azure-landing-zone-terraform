output "subnets" {
  value = {
    for k, v in azurerm_subnet.subnet : k => {
      id                   = v.id
      name                 = v.name
      address_prefixes     = v.address_prefixes
      virtual_network_name = v.virtual_network_name
      resource_group_name  = v.resource_group_name
    }
  }
  description = "Map of created Subnets with their IDs and configuration details"
}