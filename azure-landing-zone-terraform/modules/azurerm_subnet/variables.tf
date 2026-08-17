variable "subnets" {
  type = map(object({
    name                                          = string
    resource_group_name                           = string
    virtual_network_name                          = string
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  description = "Map of Subnets to create inside VNets"
}