terraform {
  backend "azurerm" {
    resource_group_name  = "my-azure-demo"
    storage_account_name = "skdemxxxxxx"
    container_name       = "sgterraform"
    key                  = "terraform.tfstate"
  }
}
