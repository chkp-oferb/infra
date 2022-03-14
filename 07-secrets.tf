locals {
    vaultid =  azurerm_key_vault_access_policy.this.key_vault_id
}
##

resource "azurerm_key_vault_secret" "sqluser" {
  name         = "dwh-sql-server-username"
  value        = data.azurerm_mssql_server.sqlsrv.administrator_login
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "sqlpass" {
  name         = "dwh-sql-server-password"
  value        = data.azurerm_key_vault_secret.sql-pass.value
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "bronzecon" {
  name         = "${azurerm_storage_account.stgacc1.name}-connection-string"
  value        = azurerm_storage_account.stgacc1.primary_connection_string
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "silvercon" {
  name         = "${azurerm_storage_account.stgacc2.name}-connection-string"
  value        = azurerm_storage_account.stgacc2.primary_connection_string
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "bronzekey" {
  name         = "${azurerm_storage_account.stgacc1.name}-key"
  value        = azurerm_storage_account.stgacc1.primary_access_key
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "silverkey" {
  name         = "${azurerm_storage_account.stgacc2.name}-key"
  value        = azurerm_storage_account.stgacc2.primary_access_key
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "goldkey" {
  name         = "${var.goldaccountname}-key"
  value        = data.azurerm_storage_account.goldaccount.primary_access_key
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "dwh-app-registration-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "client_id" {
  name         = "dwh-app-registration-client-id"
  value        = data.azurerm_key_vault_secret.app_registration_id.value
  key_vault_id = local.vaultid
}

resource "azurerm_key_vault_secret" "app_registration_secret" {
  name         = "dwh-app-registration-secret"
  value        = data.azurerm_key_vault_secret.app_registration_secret.value
  key_vault_id = local.vaultid
}

