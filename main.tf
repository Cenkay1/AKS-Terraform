locals {
    default_tags = {}
    all_tags = merge(local.default_tags, var.tags)
}
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.2"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}


resource "azurerm_resource_group" "aks_rg" {
  name = var.aks_rg_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "my-log-analytics"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.aks_name
  kubernetes_version  = var.aks_version
  private_cluster_enabled = true 
  image_cleaner_enabled = true
  role_based_access_control_enabled = true
  azure_policy_enabled = true
  tags = {
    Env = "prod"
  }

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_DS2_v2"
    os_sku = "Azure Linux"
    enable_auto_scaling = true
    max_count = 5
    min_count = 3
    vnet_subnet_id = ""
    pod_subnet_id = ""

  }
  auto_scaler_profile {
      skip_nodes_with_system_pods = true
      empty_bulk_delete_max = 2
  }

  identity {
    type = "SystemAssigned"
  }
    azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = [azuread_group.aksadmngroup.id]
  }

  network_profile {
    network_plugin = "cilium"
    dns_service_ip = ""
    service_cidr = ""
    load_balancer_sku = ""
  }
#   addon_profile {
#     kube_dashboard {
#         enable = true
#     }
#     azure_policy {
#         enabled = true
#     }
#     oms_agent {
#       enabled                    = true
#       log_analytics_workspace_id = ""
#       }
#   }
}

resource "azurerm_kubernetes_cluster_node_pool" "agent_pool" {
  name                  = "appspool"
  kubernetes_cluster_id = azurerm_arc_kubernetes_cluster.aks.id
  vm_size               = var.aks_version
  node_count            = 3
  max_pods              = 110
  node_taints = var.node_taints # İsteğe bağlı olarak node taints tanımlayabilirsin
  enable_auto_scaling  = true
  min_count            = 1
  max_count            = 5

  upgrade_settings {
    max_surge = 1
  }
  tags = {
    Env = "prod"
  }
}

resource "azurerm_container_registry" "acr" {
    name = var.acr.name
    resource_group_name = var.aks_rg_name
    sku = "Premium"
    location = var.location
    admin_enabled = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}