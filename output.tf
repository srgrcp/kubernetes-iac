output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}
