output "vnets" {
  value = {
    for k, v in azurerm_virtual_network.vnet : k => {
      id                  = v.id
      name                = v.name
      resource_group_name = v.resource_group_name
      address_space       = v.address_space
      subnets             = v.subnet
    }
  }
  description = "Map of created Virtual Networks with their details"
}