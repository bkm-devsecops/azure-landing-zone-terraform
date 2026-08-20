terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            vesrsion ="5.0.0"
        }
    }
}
provider "azurerm" {
    features {}
}