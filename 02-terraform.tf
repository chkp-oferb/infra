terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 2.95.0"
    }

    databricks = {
      source = "databrickslabs/databricks"
      version = "0.4.8"
    }
  }
  
# # Terraform state file to azure stotage account
#   backend "azurerm" {
#     resource_group_name = "datatube-terraform-state"
#     storage_account_name = "datatubeterraformbackend"
#     container_name = "tfstate"
#     key = var.tfstate
#   }

# Terraform state file to azure stotage account
  backend "azurerm" {
    
  }
}

provider "azurerm" {
    features {}
}

provider "databricks" {
  #alias = "created_workspace"
  azure_workspace_resource_id = azurerm_databricks_workspace.myworkspace.id
  #host = azurerm_databricks_workspace.myworkspace.workspace_url
  
}
