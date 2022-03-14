
locals {
  vaulturi = azurerm_key_vault.myvault.vault_uri
  #vaultid =  azurerm_key_vault_access_policy.this.key_vault_id
  senv_a = substr(var.env,0,1)
  datatubeadmins = "ecca737e-b923-4f8e-aa24-f6de07454276"
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id       = azurerm_key_vault.myvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.client_id
  secret_permissions = ["delete", "get", "list", "set"]
  depends_on = [
    databricks_cluster.live-cluster
  ]
}

resource "azurerm_key_vault_access_policy" "this_1" {
  key_vault_id       = azurerm_key_vault.myvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = local.datatubeadmins
  secret_permissions = ["delete", "get", "list", "set", "Recover", "Restore", "Backup", "Purge"]
  depends_on = [
    databricks_cluster.live-cluster
  ]
}

resource "azurerm_key_vault_access_policy" "this_2" {
  key_vault_id       = azurerm_key_vault.myvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["delete", "get", "list", "set", "Recover", "Restore", "Backup", "Purge"]
  depends_on = [
    databricks_cluster.live-cluster
  ]
}



