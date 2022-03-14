output "uri" {
  value       = azurerm_key_vault.myvault.vault_uri
  description = "The URI of the Key Vault."
}

# output "bronze-sas-key" {
#   value       = data.azurerm_storage_account_sas.brsaskey.sas
#   description = "Bronze Storage account SAS key"
# }

# output "silver-sas-key" {
#   value       = data.azurerm_storage_account_sas.silsaskey.sas
#   description = "Silver Storage account SAS key"
# }

output "sql_sever-user" {
  value       = data.azurerm_mssql_server.sqlsrv.administrator_login
  description = "DWH sql user account"
}
