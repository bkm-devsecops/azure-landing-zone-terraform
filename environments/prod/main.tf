terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote State Configuration (Azure Blob Storage for Prod State Isolation)
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate-prod"
  #   storage_account_name = "stalztfstateprod001"
  #   container_name       = "tfstate"
  #   key                  = "prod.landingzone.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

# ==============================================================================
# 1. RESOURCE GROUPS MODULE CALL
# ==============================================================================
module "resource_groups" {
  source          = "../../modules/azurerm_resource_group"
  resource_groups = var.resource_groups
}

# ==============================================================================
# 2. VIRTUAL NETWORK MODULE CALL
# ==============================================================================
module "virtual_networks" {
  source = "../../modules/azurerm_virtual_network"

  vnets = {
    vnet_spoke = {
      name                = var.vnets["vnet_spoke"].name
      location            = module.resource_groups.resource_groups["rg_network"].location
      resource_group_name = module.resource_groups.resource_groups["rg_network"].name
      address_space       = var.vnets["vnet_spoke"].address_space
      dns_servers         = var.vnets["vnet_spoke"].dns_servers
      
      tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Workload    = "Networking"
      }
    }
  }

  depends_on = [module.resource_groups]
}

# ==============================================================================
# 3. SUBNETS MODULE CALL
# ==============================================================================
module "subnets" {
  source = "../../modules/azurerm_subnet"

  subnets = {
    for k, v in var.subnets : k => {
      name                 = v.name
      resource_group_name  = module.resource_groups.resource_groups["rg_network"].name
      virtual_network_name = module.virtual_networks.vnets["vnet_spoke"].name
      address_prefixes     = v.address_prefixes
      service_endpoints    = v.service_endpoints
    }
  }

  depends_on = [module.virtual_networks]
}

# ==============================================================================
# 4. PUBLIC IP MODULE CALL
# ==============================================================================
module "public_ips" {
  source = "../../modules/azurerm_public_ip"

  public_ips = {
    for k, v in var.public_ips : k => {
      name                = v.name
      resource_group_name = module.resource_groups.resource_groups["rg_network"].name
      location            = module.resource_groups.resource_groups["rg_network"].location
      allocation_method   = "Static"
      sku                 = "Standard"
      domain_name_label   = v.domain_name_label

      tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Workload    = "Networking"
      }
    }
  }

  depends_on = [module.resource_groups]
}

# ==============================================================================
# 5. KEY VAULT MODULE CALL
# ==============================================================================
module "key_vaults" {
  source = "../../modules/azurerm_key_vault"

  key_vaults = {
    for k, v in var.key_vaults : k => {
      name                          = v.name
      resource_group_name           = module.resource_groups.resource_groups["rg_security"].name
      location                      = module.resource_groups.resource_groups["rg_security"].location
      tenant_id                     = data.azurerm_client_config.current.tenant_id
      sku_name                      = v.sku_name
      enable_rbac_authorization     = true
      purge_protection_enabled      = true
      public_network_access_enabled = v.public_network_access_enabled

      tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Workload    = "Security"
      }
    }
  }

  depends_on = [module.resource_groups]
}

# ==============================================================================
# 6. BASTION HOST MODULE CALL
# ==============================================================================
module "bastion_hosts" {
  source = "../../modules/azurerm_bastion_host"

  bastion_hosts = {
    for k, v in var.bastions : k => {
      name                 = v.name
      resource_group_name  = module.resource_groups.resource_groups["rg_network"].name
      location             = module.resource_groups.resource_groups["rg_network"].location
      sku                  = v.sku
      subnet_id            = module.subnets.subnets["snet_bastion"].id
      public_ip_address_id = module.public_ips.public_ips["pip_bastion"].id

      copy_paste_enabled   = true
      file_copy_enabled    = true
      tunneling_enabled    = true

      tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Workload    = "Management"
      }
    }
  }

  depends_on = [
    module.resource_groups,
    module.subnets,
    module.public_ips
  ]
}

# ==============================================================================
# 7. APPLICATION GATEWAY MODULE CALL
# ==============================================================================
module "application_gateways" {
  source = "../../modules/azurerm_application_gateway"

  application_gateways = {
    for k, v in var.app_gateways : k => {
      name                 = v.name
      resource_group_name  = module.resource_groups.resource_groups["rg_network"].name
      location             = module.resource_groups.resource_groups["rg_network"].location
      subnet_id            = module.subnets.subnets["snet_agw"].id
      public_ip_id         = module.public_ips.public_ips["pip_agw"].id
      capacity             = v.capacity
      backend_ip_addresses = ["10.20.1.4"] # Target App VM IP inside Prod App Subnet

      tags = {
        Environment = var.environment
        ManagedBy   = "Terraform"
        Workload    = "Ingress"
      }
    }
  }

  depends_on = [
    module.resource_groups,
    module.subnets,
    module.public_ips
  ]
}