output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "credential_configuration" {
  value = databricks_mws_credentials.this.credentials_id
}

output "storage_configuration" {
  value = databricks_mws_credentials.this.credentials_id
}

output "network_configuration" {
  value = databricks_mws_credentials.this.credentials_id
}

output "managed_services_customer_managed_key_id" {
  value = databricks_mws_customer_managed_keys.managed_storage.customer_managed_key_id
}

output "storage_customer_managed_key_id" {
  value = databricks_mws_customer_managed_keys.workspace_storage.customer_managed_key_id
}