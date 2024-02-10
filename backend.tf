terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate74ong"
    container_name       = "tfstate"
    key                  = "jenkins.tfstate"
  }
}
