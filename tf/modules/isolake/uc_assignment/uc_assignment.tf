// Metastore Assignment
resource "databricks_metastore_assignment" "default_metastore" {
  workspace_id         = var.databricks_workspace_id
  metastore_id         = var.metastore_id
  default_catalog_name = "main"
}