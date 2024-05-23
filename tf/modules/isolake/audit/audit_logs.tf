resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "30s"
}
// Databricks Credential Configuration for Logs
resource "databricks_mws_credentials" "log_writer" {
  account_id       = var.databricks_account_id
  credentials_name = "${var.resource_prefix}-log-delivery-credential"
  role_arn         = aws_iam_role.log_delivery.arn
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}

// Databricks Storage Configuration for Logs
resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.resource_prefix}-log-delivery-bucket"
  bucket_name                = aws_s3_bucket.log_delivery.bucket
  depends_on = [
    aws_s3_bucket_policy.log_delivery
  ]
}

// Databricks Audit Logs Configurations
resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "Audit Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
  depends_on = [
    aws_s3_bucket_policy.log_delivery,
    aws_iam_role_policy.log_delivery_policy,
    time_sleep.wait_30_seconds
  ]
}