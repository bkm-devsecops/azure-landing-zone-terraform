variable "public_ips" {
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    allocation_method   = optional(string, "Static")
    sku                 = optional(string, "Standard")
    zones               = optional(list(string), ["1", "2", "3"])
    domain_name_label   = optional(string, null)
    tags                = optional(map(string), {})
  }))
  description = "Map of Public IPs to create"
}