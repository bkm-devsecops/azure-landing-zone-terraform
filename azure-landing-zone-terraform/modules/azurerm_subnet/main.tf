resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                                          = each.value.name
  resource_group_name                           = each.value.resource_group_name
  virtual_network_name                          = each.value.virtual_network_name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
}