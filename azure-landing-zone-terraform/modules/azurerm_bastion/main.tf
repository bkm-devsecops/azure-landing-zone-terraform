resource "azurerm_bastion_host" "bastion" {
  for_each = var.bastion_hosts

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  scale_units         = each.value.sku == "Standard" ? each.value.scale_units : 2
  copy_paste_enabled  = each.value.copy_paste_enabled
  file_copy_enabled   = each.value.sku == "Standard" ? each.value.file_copy_enabled : null
  ip_connect_enabled  = each.value.sku == "Standard" ? each.value.ip_connect_enabled : null
  tunneling_enabled   = each.value.sku == "Standard" ? each.value.tunneling_enabled : null
  tags                = each.value.tags

  ip_configuration {
    name                 = "${each.value.name}-ipconfig"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = each.value.public_ip_address_id
  }
}