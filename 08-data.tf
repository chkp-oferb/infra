
data "azurerm_storage_account" "goldaccount" {
  name                = var.goldaccountname
  resource_group_name = var.goldaccountrg
}

data "azurerm_mssql_server" "sqlsrv" {
  name                = var.sqlname
  resource_group_name = var.sqlrg
}

data "azurerm_key_vault" "allvault" {
  name                = "${var.allvaultname}"
  resource_group_name = "${var.allvaultrg}"
}

data "azurerm_key_vault_secret" "sql-pass" {
  name         = "dwh-sql-server-password"
  key_vault_id = data.azurerm_key_vault.allvault.id
}

data "azurerm_key_vault_secret" "app_registration_secret" {
  name         = "dwh-app-registration-secret"
  key_vault_id = data.azurerm_key_vault.allvault.id
}

data "azurerm_key_vault_secret" "app_registration_id" {
  name         = "dwh-app-registration-client-id"
  key_vault_id = data.azurerm_key_vault.allvault.id
}
