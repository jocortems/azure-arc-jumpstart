terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "= 2.0.0-beta"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

data "azurerm_resource_group" "arc_rg" {
  name = var.resource_group_name
}

locals {
  dashboard_files = ["Arc - Deployment Progress.json", "Arc - Estate Profile.json", "Arc - ESU.json", "Arc - Server Deployment.json", "Arc - SQL Server Inventory.json", "SQL Server Estate Health.json", "SQL Server Instances.json"]
}

resource "azapi_resource" "sql_arc_dashboards" {
  for_each = { for file in local.dashboard_files : trimsuffix(file, ".json") => file }

  type      = "Microsoft.Portal/dashboards@2022-12-01-preview"
  name      = replace(each.key, " ", "")
  parent_id = data.azurerm_resource_group.arc_rg.id
  location  = data.azurerm_resource_group.arc_rg.location
  schema_validation_enabled = false
  tags = {
    hidden-title = each.key
  }
  body = jsondecode(file(each.value))
}


