output "application_gateways" {
  value = {
    for k, v in azurerm_application_gateway.agw : k => {
      id   = v.id
      name = v.name
    }
  }
  description = "Map of created Application Gateways with their Resource IDs"
}