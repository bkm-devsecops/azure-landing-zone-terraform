variable "bastion_hosts" {
  type = map(object({
    name                 = string
    resource_group_name  = string
    location             = string
    copy_paste_enabled   = optional(bool, true)
    file_copy_enabled    = optional(bool, false)
    sku                  = optional(string, "Standard") # Basic or Standard
    scale_units          = optional(number, 2)
    ip_connect_enabled   = optional(bool, false)
    tunneling_enabled    = optional(bool, false)
    subnet_id            = string
    public_ip_address_id = string
    tags                 = optional(map(string), {})
  }))
  description = "Map of Azure Bastion Hosts to create"
}