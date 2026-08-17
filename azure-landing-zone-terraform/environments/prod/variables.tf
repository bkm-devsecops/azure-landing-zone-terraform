variable "environment" {
  type        = string
  description = "Environment name (e.g., prod)"
}

variable "location" {
  type        = string
  description = "Primary Azure Region"
}

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  description = "Map of Production Resource Groups"
}

variable "vnets" {
  type = map(object({
    name          = string
    address_space = list(string)
    dns_servers   = optional(list(string))
  }))
  description = "Map of Production VNets"
}

variable "subnets" {
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  description = "Map of Production Subnets"
}

variable "public_ips" {
  type = map(object({
    name              = string
    domain_name_label = optional(string, null)
  }))
  description = "Map of Production Public IPs"
}

variable "key_vaults" {
  type = map(object({
    name                          = string
    sku_name                      = optional(string, "standard")
    public_network_access_enabled = optional(bool, false)
  }))
  description = "Map of Production Key Vaults"
}

variable "bastions" {
  type = map(object({
    name = string
    sku  = optional(string, "Standard")
  }))
  description = "Map of Production Bastion Hosts"
}

variable "app_gateways" {
  type = map(object({
    name     = string
    capacity = optional(number, 2)
  }))
  description = "Map of Production Application Gateways"
}