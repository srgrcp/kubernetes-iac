provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "az"
    args        = ["aks", "get-credentials", "--resource-group", azurerm_resource_group.aks-rs.name, "--name", azurerm_kubernetes_cluster.aks.name]
  }
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate = base64decode(
      azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
    )
    client_key = base64decode(
      azurerm_kubernetes_cluster.aks.kube_config.0.client_key
    )
    cluster_ca_certificate = base64decode(
      azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
    )
  }
}
