variable "application_gateways" {
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    
    # SKU Settings
    sku_name     = optional(string, "Standard_v2")
    sku_tier     = optional(string, "Standard_v2")
    capacity     = optional(number, 2)
    
    # Networking
    subnet_id           = string
    public_ip_id        = string
    
    # Frontend Ports
    frontend_port_80    = optional(number, 80)
    frontend_port_443   = optional(number, 443)
    
    # Target Backend Settings
    backend_ip_addresses = optional(list(string), [])
    
    tags = optional(map(string), {})
  }))
  description = "Map of Application Gateways to create"
}