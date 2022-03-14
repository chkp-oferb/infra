
# variable "uri" {
#   description = "uri of the vault"
#   type = string
# }

variable "rg-prefix" {
  description = "This prefix will be included in the name of resource-groups"
  default = "databricks-dwh"
}

variable "bdp-prefix" {
  description = "This prefix will be included in the name of dbd."
  default = "bdp-databricks"
}

variable "azureadapplication" {
  description = "App registration ID."
  default = "Place Holder"
}

variable "env" {
  description = "This suffix will be included in the name in the name of dbrix."
  default = "placeholder"
}

variable "location" {
  description = "The region"
  default     = "placeholder"
}

variable "stgaccbronze" {
  description = "Storage account name"
  default     = "dwhbr"
}

variable "stgaccsilver" {
  description = "Storage account name"
  default     = "dwhsi"
}

variable "vaultprefix" {
  description = "Storage account name"
  default     = "cpdwh"
}

variable "spark_version" {
  description = "Spark Runtime Version for databricks clusters"
  default     = "9.1.x-scala2.12"
}

variable "node_type_id" {
  description = "Type of worker nodes for databricks clusters"
  default     = "Standard_DS3_v2"
}

variable "core_notebook_path" {
  description = "Path to a notebook"
  type        = list(string)
  default     = ["/Repos/dwh/bdp-data-warehouse/core/dim apps details",
                 "/Repos/dwh/bdp-data-warehouse/core/dim tenant apps",
                 "/Repos/dwh/bdp-data-warehouse/core/dim tenants",
                 "/Repos/dwh/bdp-data-warehouse/core/dim user tenants",
                 "/Repos/dwh/bdp-data-warehouse/core/dim users",
                 "/Repos/dwh/bdp-data-warehouse/cloudinfra/fact audits"]
}

variable "datatubeusage_notebook_path" {
  description = "Path to a notebook"
  type        = list(string)
  default     = ["/Repos/dwh/bdp-data-warehouse/datatube_usage/fact datatube usage",
                 "/Repos/dwh/bdp-data-warehouse/datatube_usage/fact azure cost",
                 "/Repos/dwh/bdp-data-warehouse/datatube_usage/fact datatube storage",
                 "/Repos/dwh/bdp-data-warehouse/datatube_usage/fact datatube cost" ]
}

variable "dailymigration_notebook_path" {
  description = "Path to a notebook"
  type        = list(string)
  default     = ["/Repos/dwh/bdp-data-warehouse/sql server migration/daily migration"]
}

# variable "min_workers" {
#   description = "Minimum workers in a cluster"
#   default     = 1
# }

# variable "max_workers" {
#   description = "Maximum workers in a cluster"
#   default     = 4
# }

variable "goldaccountname" {
  description = "gold account name"
  default = "placeholder"
}

variable "goldaccountrg" {
  description = "gold account resource group"
  default = "placeholder"
}

variable "sqlname" {
  description = "sql server name"
  default = "placeholder"
}

variable "sqlrg" {
  description = "sql resource group"
  default = "placeholder"
}

variable "clusterenvvar" {
  description = "databricks cluster env var "
  default = "prod"
}

variable "allvaultname" {
  description = "Vault name to store sql password"
  default = "Place Holder"
}

variable "allvaultrg" {
  description = "Vault rg to store sql password"
  default = "Place Holder"
}