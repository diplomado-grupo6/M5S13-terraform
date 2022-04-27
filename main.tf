resource "azurerm_resource_group" "resource-group" {
  name     = var.name
  location = var.location
  tags     = {
    diplomado = "diplotag"
  }
}

resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "virtual-network"
  address_space       = ["12.0.0.0/16"]
  resource_group_name = azurerm_resource_group.resource-group.name
  location            = azurerm_resource_group.resource-group.location
}

resource "azurerm_subnet" "subnet" {
  name = "internalsubnet"
  resource_group_name = azurerm_resource_group.resource-group.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes = ["12.0.0.0/20"]
}


resource "azurerm_kubernetes_cluster" "kubernetescluster" {
  name                = "aksdiplomado"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  dns_prefix          = "aks1"
  kubernetes_version  = "1.22.4"
  role_based_access_control_enabled = true

  default_node_pool  {
    name                 = "default"
    node_count           = 1
    vm_size              = "standard_dc2ds_v3"
    vnet_subnet_id       = azurerm_subnet.subnet.id
    enable_auto_scaling = true
    min_count            = 1
    max_count            = 3
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "aksnodepool" {
  name                  = "internalpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetescluster.id
  vm_size               = "standard_dc2ds_v3"
  node_count            = 1
  max_pods              = 80
  node_labels = {
    nodepool_label = "nodepool1"
  }
}

variable "name" {
}

variable "location" {
}

variable "client_id" {
}

variable "client_secret" {
}

variable "subscription_id" {
}

variable "tenant_id" {
}
