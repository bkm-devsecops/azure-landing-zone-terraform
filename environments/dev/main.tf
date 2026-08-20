module "resource_group" {
    source = "../../modules/azurerm_resource_group"
     resource_groups = var.resource_groups
  
}