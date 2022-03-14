data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}
data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  senv = substr(var.env,0,1)
  rgname = azurerm_resource_group.dbdrg.name
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
  fromdate = timestamp()
  #stateenv = "stg"
}

resource "azurerm_resource_group" "dbdrg" {
  name     = "${var.rg-prefix}-${var.location}-${var.env}"
  location = var.location
  tags = {
    environment = "${var.env}"
    location    = "${var.location}"
    application = "dwh-databricks"
  }
}

resource "azurerm_key_vault" "myvault" {
  name                        = "${var.vaultprefix}-${var.location}-${local.senv_a}"
  location                    = "${var.location}"
  resource_group_name         = azurerm_resource_group.dbdrg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["${local.ifconfig_co_json.ip}/32"]
  }
}

resource "azurerm_storage_account" "stgacc1" {
  name                     = "${var.stgaccbronze}${var.location}${local.senv}" 
  resource_group_name      = local.rgname
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  tags = {
    environment = "${var.env}"
    location    = "${var.location}"
    application = "dwh-databricks"

  }
}

resource "azurerm_storage_account" "stgacc2" {
  name                     = "${var.stgaccsilver}${var.location}${local.senv}" 
  resource_group_name      = local.rgname
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true


  tags = {
    environment = "${var.env}"
    location    = "${var.location}"
    application = "dwh-databricks"
  }
}

resource "azurerm_role_assignment" "role" {
  scope                = azurerm_storage_account.stgacc1.id
  role_definition_name = "Contributor"
  principal_id         = var.azureadapplication
  }

# ------------  Bronze containers 

resource "azurerm_storage_container" "azurecost" {
  name                  = "azurecost"
  storage_account_name  = azurerm_storage_account.stgacc1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "cloudinfrapostgress" {
  name                  = "cloudinfrapostgress"
  storage_account_name  = azurerm_storage_account.stgacc1.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "datatube" {
  name                  = "datatube"
  storage_account_name  = azurerm_storage_account.stgacc1.name
  container_access_type = "private"
}

# ------------  Silver containers

resource "azurerm_storage_container" "cloudinfra" {
  name                  = "cloudinfra"
  storage_account_name  = azurerm_storage_account.stgacc2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "core" {
  name                  = "core"
  storage_account_name  = azurerm_storage_account.stgacc2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "datatubeusage" {
  name                  = "datatubeusage"
  storage_account_name  = azurerm_storage_account.stgacc2.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "sparkstreamcheckpoints" {
  name                  = "sparkstreamcheckpoints"
  storage_account_name  = azurerm_storage_account.stgacc2.name
  container_access_type = "private"
}

# # ----------- Generate SAS

# data "azurerm_storage_account_sas" "brsaskey" {
#   connection_string = azurerm_storage_account.stgacc1.primary_connection_string
#   https_only        = true
#   signed_version    = local.fromdate

#   resource_types {
#     service   = false
#     container = false
#     object    = true
#   }

#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }

#   start  = local.fromdate
#   expiry = "2028-01-21T00:00:00Z"

#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     update  = true
#     process = true
#   }
# }

# data "azurerm_storage_account_sas" "silsaskey" {
#   connection_string = azurerm_storage_account.stgacc1.primary_connection_string
#   https_only        = true
#   signed_version    = local.fromdate

#   resource_types {
#     service   = false
#     container = false
#     object    = true
#   }

#   services {
#     blob  = true
#     queue = false
#     table = false
#     file  = false
#   }

#   start  = local.fromdate
#   expiry = "2028-01-21T00:00:00Z"

#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     update  = true
#     process = true
#   }
# }
