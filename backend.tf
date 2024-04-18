terraform {
  backend "azurerm" {
    resource_group_name  = "my-azure-demo"
    storage_account_name = "skdemosgv2"
    container_name       = "sgterraform"
    key                  = "terraform.tfstate"
  }
}
