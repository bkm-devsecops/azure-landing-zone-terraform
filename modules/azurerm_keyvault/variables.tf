variable "key_vaults" {
  type = map(object({
    name                            = string
    resource_group_name             = string
    location                        = string
    tenant_id                       = string
    sku_name                        = optional(string, "standard")
    enabled_for_disk_encryption     = optional(bool, true)
    purge_protection_enabled        = optional(bool, true)
    soft_delete_retention_days      = optional(number, 7)
    enable_rbac_authorization       = optional(bool, true)
    public_network_access_enabled   = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  description = "Map of Key Vaults to create"
}