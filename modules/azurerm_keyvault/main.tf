resource "azurerm_key_vault" "kv" {
  for_each = var.key_vaults

  name                            = each.value.name
  location                        = each.value.location
  resource_group_name             = each.value.resource_group_name
  tenant_id                       = each.value.tenant_id
  sku_name                        = each.value.sku_name
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  purge_protection_enabled        = each.value.purge_protection_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  enable_rbac_authorization       = each.value.enable_rbac_authorization
  public_network_access_enabled   = each.value.public_network_access_enabled
  tags                            = each.value.tags
}