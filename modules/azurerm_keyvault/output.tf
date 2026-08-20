output "key_vaults" {
  value = {
    for k, v in azurerm_key_vault.kv : k => {
      id                  = v.id
      name                = v.name
      vault_uri           = v.vault_uri
      resource_group_name = v.resource_group_name
    }
  }
  description = "Map of created Key Vaults with their IDs and URIs"
}