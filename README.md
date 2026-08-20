# ☁️ Azure Landing Zone Terraform (CAF Aligned)

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.3.0-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Security: DevSecOps](https://img.shields.io/badge/Security-DevSecOps%20Guardrails-green?style=for-the-badge&logo=azuredevops)](https://azure.microsoft.com/en-us/solutions/devops/)

An enterprise-grade, modular **Azure Landing Zone (ALZ)** implementation using **Terraform**, architected according to the **Microsoft Cloud Adoption Framework (CAF)**. This repository provides foundational infrastructure, network isolation, centralized security, ingress control, and governance across multi-environment deployments (`dev`, `prod`).

---

## 📑 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Repository Structure](#-repository-structure)
- [Core Modules](#-core-modules)
- [Environment Configurations](#-environment-configurations)
- [Prerequisites](#-prerequisites)
- [Quick Start Guide](#-quick-start-guide)
  - [1. Azure Authentication](#1-azure-authentication)
  - [2. Remote State Setup](#2-remote-state-setup-recommended-for-prod)
  - [3. Deployment Steps](#3-deployment-steps)
- [Security & Governance Guardrails](#-security--governance-guardrails)
- [Input Variables & Customization](#-input-variables--customization)
- [CI/CD & DevSecOps Validation](#-cicd--devsecops-validation)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🏛️ Architecture Overview

The Landing Zone establishes a segmented and secure cloud topology:

```
                              +-------------------------------------------------------------+
                              |                  Azure Subscription                         |
                              |                                                             |
                              |  +-------------------------------------------------------+  |
                              |  |        Resource Group: rg-alz-network-prod-eastus-01  |  |
                              |  |                                                       |  |
                              |  |  +-------------------------------------------------+  |  |
                              |  |  |           Virtual Network: vnet-spoke           |  |  |
                              |  |  |                 (10.20.0.0/16)                  |  |  |
                              |  |  |                                                 |  |  |
+-------------------+         |  |  |  +--------------------+   +-------------------+ |  |  |
| Internet / Users  |-------->|  |  |  | snet-agw           |   | AzureBastionSubnet| |  |  |
+-------------------+         |  |  |  | (10.20.10.0/24)    |   | (10.20.250.0/26)  | |  |  |
                              |  |  |  | [App Gateway (WAF)]|   | [Azure Bastion]   | |  |  |
                              |  |  |  +---------+----------+   +---------+---------+ |  |  |
                              |  |  |            |                        |           |  |  |
                              |  |  |            v                        v           |  |  |
                              |  |  |  +--------------------+   +-------------------+ |  |  |
                              |  |  |  | snet-app           |   | snet-db           | |  |  |
                              |  |  |  | (10.20.1.0/24)     |   | (10.20.2.0/24)    | |  |  |
                              |  |  |  | [Workload VMs]     |   | [Database Tier]   | |  |  |
                              |  |  |  +---------+----------+   +-------------------+ |  |  |
                              |  |  +------------|------------------------------------+  |  |
                              |  +---------------|---------------------------------------+  |
                              |                  | (Service Endpoints: Storage/KV)          |
                              |                  v                                          |
                              |  +-------------------------------------------------------+  |
                              |  |        Resource Group: rg-alz-security-prod-eastus-01 |  |
                              |  |  +-------------------------------------------------+  |  |
                              |  |  | Azure Key Vault (RBAC, Purge Protection)        |  |  |
                              |  |  +-------------------------------------------------+  |  |
                              |  +-------------------------------------------------------+  |
                              +-------------------------------------------------------------+
```

### Key Architectural Highlights:
- **Layer 7 Ingress Traffic Routing**: Azure Application Gateway handles SSL termination and routing to backend application instances.
- **Secure Management Access**: Azure Bastion provides zero-exposure RDP/SSH access without public IPs on virtual machines.
- **Micro-Segmentation**: Dedicated subnets for Web/Ingress, Application, Database, and Management tiers.
- **Centralized Secrets & Encryption**: Azure Key Vault configured with RBAC authorization, soft-delete, and purge protection enabled.
- **Resource Segregation**: Clear separation of duties across dedicated Resource Groups (`Network`, `Security`, `Application`).

---

## 📂 Repository Structure

```plaintext
azure-landing-zone-terraform/
├── .github/                        # CI/CD Workflows (GitHub Actions)
├── environments/                   # Environment-specific orchestrations
│   ├── dev/                        # Development environment configuration
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── provider.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── prod/                       # Production environment configuration
│       ├── main.tf
│       ├── provider.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── modules/                        # Reusable Terraform infrastructure modules
│   ├── azurerm_application_gateway/# App Gateway (WAF / Load Balancer) module
│   ├── azurerm_bastion/            # Azure Bastion Host module
│   ├── azurerm_keyvault/           # Azure Key Vault module
│   ├── azurerm_public_ip/          # Public IP management module
│   ├── azurerm_resource_group/     # Resource Group provisioning module
│   ├── azurerm_subnet/             # Subnets & Service Endpoints module
│   ├── azurerm_virtual_machine/    # Virtual Machine workload module
│   └── azurerm_virtual_network/    # Virtual Network (VNet) topology module
├── .gitignore                      # Git ignore file for Terraform artifacts
├── main.tf                         # Root entrypoint
└── README.md                       # Project documentation
```

---

## 🧱 Core Modules

| Module Name | Source Path | Description |
| :--- | :--- | :--- |
| **Resource Group** | [`modules/azurerm_resource_group`](modules/azurerm_resource_group/) | Creates isolated resource groups with standardized tags and regions. |
| **Virtual Network** | [`modules/azurerm_virtual_network`](modules/azurerm_virtual_network/) | Deploys hub/spoke VNets, address spaces, and custom DNS servers. |
| **Subnet** | [`modules/azurerm_subnet`](modules/azurerm_subnet/) | Creates segmented subnets with Service Endpoints and delegation support. |
| **Public IP** | [`modules/azurerm_public_ip`](modules/azurerm_public_ip/) | Deploys Static, Standard SKU Public IPs with DNS labels. |
| **Key Vault** | [`modules/azurerm_keyvault`](modules/azurerm_keyvault/) | Azure Key Vault with RBAC, purge protection, soft-delete, and network controls. |
| **Bastion Host** | [`modules/azurerm_bastion`](modules/azurerm_bastion/) | Deploys Azure Bastion with native copy-paste, file copy, and IP connect support. |
| **Application Gateway** | [`modules/azurerm_application_gateway`](modules/azurerm_application_gateway/) | L7 Load Balancer with HTTP/HTTPS listeners, routing rules, and backend pools. |
| **Virtual Machine** | [`modules/azurerm_virtual_machine`](modules/azurerm_virtual_machine/) | Workload Compute instances (Linux/Windows) with NICs and data disks. |

---

## 🌍 Environment Configurations

| Environment | Directory | Purpose & Characteristics |
| :--- | :--- | :--- |
| **Dev** | [`environments/dev/`](environments/dev/) | Lightweight configuration for fast testing, validation, and cost efficiency. |
| **Prod** | [`environments/prod/`](environments/prod/) | Production-grade high availability (HA), multi-instance App Gateway, strict RBAC, Key Vault purge protection, and remote state isolation. |

---

## ⚙️ Prerequisites

Before provisioning, ensure you have the following installed and configured:

1. **[Terraform CLI](https://developer.hashicorp.com/terraform/downloads)** (v1.3.0 or higher)
2. **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)** (v2.40.0 or higher)
3. **Active Azure Subscription** with permissions:
   - `Contributor` or `Owner` on the target subscription
   - `Key Vault Administrator` / `User Access Administrator` for RBAC assignments

---

## 🚀 Quick Start Guide

### 1. Azure Authentication

Login to your Azure account and select the appropriate subscription:

```bash
# Authenticate with Azure CLI
az login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "<YOUR_SUBSCRIPTION_ID_OR_NAME>"
```

### 2. Remote State Setup (Recommended for Prod)

For production state locking and collaboration, enable the Azure Blob Storage backend in `environments/prod/main.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod"
    storage_account_name = "<unique_storage_account_name>"
    container_name       = "tfstate"
    key                  = "prod.landingzone.tfstate"
  }
}
```

### 3. Deployment Steps

Navigate to the target environment directory (e.g., `environments/prod`):

```bash
# Navigate to the environment
cd environments/prod

# 1. Initialize Terraform (downloads providers & modules)
terraform init

# 2. Format and validate configuration
terraform fmt -check
terraform validate

# 3. Preview execution plan
terraform plan -out=tfplan.binary

# 4. Apply changes
terraform apply tfplan.binary
```

To tear down deployed resources:

```bash
terraform destroy
```

---

## 🔒 Security & Governance Guardrails

This Landing Zone enforces enterprise DevSecOps standards:

- **Zero-Trust Network Access**: All virtual machines sit on private subnets with no public IPs assigned directly to compute instances.
- **Bastion Tunneling**: Admin access occurs strictly through encrypted TLS sessions via Azure Bastion (`AzureBastionSubnet`).
- **Key Vault Hardening**:
  - `purge_protection_enabled = true` prevents accidental or malicious secret deletion.
  - `soft_delete_retention_days` configured for recovery.
  - `enable_rbac_authorization = true` enforces Azure Entra ID fine-grained permissions.
  - `public_network_access_enabled = false` restricts Key Vault exposure in production.
- **Resource Tagging Taxonomy**: Mandatory tagging for resource attribution:
  ```hcl
  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Workload    = "Networking" # or "Security", "Application"
  }
  ```

---

## 📊 Input Variables & Customization

Key configurable variables in `terraform.tfvars`:

| Variable | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `environment` | `string` | Deployment environment name | `"prod"` / `"dev"` |
| `location` | `string` | Primary Azure region | `"eastus"` |
| `resource_groups` | `map(object)` | Map of Resource Groups with workload tags | `rg_network`, `rg_security`, `rg_app` |
| `vnets` | `map(object)` | Spoke VNet configuration and CIDR | `10.20.0.0/16` |
| `subnets` | `map(object)` | Subnet CIDRs and Service Endpoints | `10.20.1.0/24`, `10.20.2.0/24` |
| `public_ips` | `map(object)` | Public IP configurations | `pip_agw`, `pip_bastion` |
| `key_vaults` | `map(object)` | Key Vault security configurations | `kv-alz-sec-prod-eastus-01` |
| `bastions` | `map(object)` | Azure Bastion SKU & scaling | `Standard` |
| `app_gateways` | `map(object)` | App Gateway capacity & backend routing | `capacity = 3` |

---

## 🛠️ CI/CD & DevSecOps Validation

Integrate with automated pipelines using static analysis and security scanning tools:

```bash
# 1. Format Check
terraform fmt -recursive -check

# 2. Syntax Validation
terraform validate

# 3. Security Scanning with tfsec / Trivy
tfsec .
# or
trivy config .

# 4. Policy Check with Checkov
checkov -d .
```

---

## 🤝 Contributing

1. Fork the repository.
2. Create a descriptive feature branch:
   ```bash
   git checkout -b feature/new-module-name
   ```
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat(network): add NSG association support"
   ```
4. Push to your branch and open a Pull Request.

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <b>Built with ❤️ by Brajendra Mishra for Enterprise Azure Adoption</b>
</p>
