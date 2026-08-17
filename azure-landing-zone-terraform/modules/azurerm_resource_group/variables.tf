variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  description = "Map of Resource Groups to create"
}