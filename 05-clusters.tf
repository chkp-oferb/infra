locals {
  databricks_instance = "https://${azurerm_databricks_workspace.myworkspace.workspace_url}/api/2.0/workspace-conf"
  vault-uri = azurerm_key_vault.myvault.vault_uri
}

resource "azurerm_databricks_workspace" "myworkspace" {
  location                      = azurerm_resource_group.dbdrg.location
  name                          = "${var.bdp-prefix}-${var.env}-${var.location}"
  resource_group_name           = azurerm_resource_group.dbdrg.name
  sku                           = "standard"
}

resource "databricks_cluster" "live-cluster" {
  cluster_name            = "${var.env}_${var.location}-Playground"
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  num_workers             = 0
  autotermination_minutes = 90
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }
  
  custom_tags = {
    ResourceClass: "SingleNode"
  }
  library {
    pypi {
        package = "azure-storage-blob"
         }
    }
    library {
    pypi {
        package = "azure-kusto-data"
         }
    }
  spark_env_vars = {
      PYSPARK_PYTHON = "/databricks/python3/bin/python3"
      REGION = "${var.location}"
      ENV = var.clusterenvvar
  }   
}

resource "databricks_cluster" "dwh" {
  cluster_name            = "${var.env}_${var.location}-jobs"
  spark_version           = var.spark_version
  node_type_id            = var.node_type_id
  num_workers             = 0
  autotermination_minutes = 10
  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }
  custom_tags = {
    ResourceClass: "SingleNode"
  }
  library {
    pypi {
        package = "azure-storage-blob"
         }
    }
    library {
    pypi {
        package = "azure-kusto-data"
         }
    }
  spark_env_vars = {
      PYSPARK_PYTHON = "/databricks/python3/bin/python3"
      REGION = "${var.location}"
      ENV = var.clusterenvvar
  }   
}

#    --------  Cluster with workers -------------------

# resource "databricks_cluster" "dwh" {
#   cluster_name            = "${var.env}_${var.location}_jobs"
#   spark_version           = var.spark_version
#   node_type_id            = var.node_type_id
#   autotermination_minutes = 10
#   autoscale {
#     min_workers = var.min_workers
#     max_workers = var.max_workers
#   }
#   library {
#     pypi {
#         package = "azure-storage-blob"
#          }
#     }
#     library {
#     pypi {
#         package = "azure-kusto-data"
#          }
#     }
#   spark_env_vars = {
#       PYSPARK_PYTHON = "/databricks/python3/bin/python3"
#       REGION = "${var.location}"
#       ENV = "${var.env}"
#   }   
# }

resource "databricks_secret_scope" "kv" {
  name = "dwh-vault4databricks"
  backend_type = "AZURE_KEYVAULT"
  keyvault_metadata {
    resource_id = azurerm_key_vault.myvault.id  
    dns_name    = local.vaulturi
    
  }
  initial_manage_principal = "users"
  depends_on = [
    azurerm_databricks_workspace.myworkspace
  ]
}
     
resource "databricks_job" "corejob" {
  name = "core"
  task {
    task_key = "dim_apps_details"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[0]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  format = "MULTI_TASK"
  task {
    task_key = "dim_tenant_apps"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[1]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  
  task {
    task_key = "dim_tenants"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[2]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "dim_user_tenants"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[3]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "dim_users"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[4]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "fact_audit"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.core_notebook_path[5]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  schedule  {
      quartz_cron_expression = "54 0 8 * * ?"
      timezone_id =  "Asia/Jerusalem"
      pause_status = "UNPAUSED" 
  }
}

resource "databricks_job" "datatubeusage_job" {
  name = "datatube usage"
  task {
    task_key = "fact_datatube_usage"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.datatubeusage_notebook_path[0]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "fact_azure_cost"
    timeout_seconds = 180
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.datatubeusage_notebook_path[1]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "fact_datatube_storage"
    timeout_seconds = 180
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.datatubeusage_notebook_path[2]
    }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  task {
    task_key = "fact_datatube_cost"
    timeout_seconds = 180
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 120000
    notebook_task {
      notebook_path = var.datatubeusage_notebook_path[3]
    }
    depends_on {
       task_key = "fact_datatube_usage" 
     }
     depends_on {
       task_key = "fact_azure_cost" 
     }
     depends_on {
       task_key = "fact_datatube_storage" 
     }
    existing_cluster_id = databricks_cluster.dwh.id
  }
  schedule  {
      quartz_cron_expression = "16 30 8 * * ?"
      timezone_id =  "Asia/Jerusalem"
      pause_status = "UNPAUSED" 
  }
}

resource "databricks_job" "dailymigratione_job" {
  name = "daily migration"
  task {
    task_key = "daily_migration"
    timeout_seconds = 300
    max_retries = 2
    retry_on_timeout = true
    min_retry_interval_millis = 60000
    
    notebook_task {
      notebook_path = var.dailymigration_notebook_path[0]
    }
      
      existing_cluster_id = databricks_cluster.dwh.id
  }
  format = "MULTI_TASK"
  schedule  {
      quartz_cron_expression = "12 0 10 * * ?"
      timezone_id =  "Asia/Jerusalem"
      pause_status = "UNPAUSED" 
  }

  max_concurrent_runs = 1
}


resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableJawsMultitasking" : true
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [
      local.databricks_instance 
  ]
}

// create PAT token to provision entities within workspace
resource "databricks_token" "pat" {
  provider = databricks
  comment  = "Terraform Provisioning"
  // 100 day token
  lifetime_seconds = 8640000
  depends_on = [
    databricks_cluster.live-cluster
  ]
}

