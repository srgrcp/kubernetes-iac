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

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

resource "kubernetes_storage_class_v1" "azure-storage-class" {
  metadata {
    name = "azure-standard-ssd"
  }

  storage_provisioner = "disk.csi.azure.com"
  parameters = {
    skuName = "StandardSSD_LRS"
  }
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "kube-prometheus-stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.prometheus.metadata.0.name
  create_namespace = true

}

resource "kubernetes_ingress_v1" "grafana-ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = kubernetes_namespace.prometheus.metadata.0.name
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kube-prometheus-stack-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
