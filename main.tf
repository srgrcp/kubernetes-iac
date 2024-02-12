locals {
  cluster_name = var.CLUSTER_NAME
}

resource "azurerm_resource_group" "aks-rs" {
  name     = "aks-example"
  location = var.LOCATION
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.cluster_name
  location            = azurerm_resource_group.aks-rs.location
  resource_group_name = azurerm_resource_group.aks-rs.name
  dns_prefix          = local.cluster_name

  default_node_pool {
    name                        = "default"
    vm_size                     = "Standard_B2as_v2"
    enable_auto_scaling         = true
    min_count                   = 1
    max_count                   = 3
    os_disk_size_gb             = 32
    temporary_name_for_rotation = "tempnodepool"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
    Project     = "learning-devops"
  }
}

resource "kubernetes_namespace" "srgrcp" {
  metadata {
    name = "srgrcp"
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
}
