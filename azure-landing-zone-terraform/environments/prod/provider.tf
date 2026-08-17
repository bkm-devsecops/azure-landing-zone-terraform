terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0" # Ya latest 3.x / 4.x major version
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }

  # Enterprise-grade Remote Backend with State Locking
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod-eastus-01"
    storage_account_name = "stalztfstateprodeastus01"
    container_name       = "tfstate"
    key                  = "prod.landingzone.tfstate"
    use_azuread_auth     = true # Key-less authentication for Azure DevOps / GitHub Actions CI/CD
  }
}

# Provider Configuration
provider "azurerm" {
  features {
    # Key Vault Deletion Rules for Enterprise Protection
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    # Resource Group level safeguards
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  # Explicit Subscription ID pass karne ke liye (Optionally)
  # subscription_id = var.subscription_id
}

provider "azuread" {
  # Configuration options for Azure AD / Entra ID
}