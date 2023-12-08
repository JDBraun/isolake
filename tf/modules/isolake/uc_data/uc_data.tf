resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

// Storage Credential
resource "databricks_storage_credential" "external" {
  name = aws_iam_role.storage_credential_role.id
  aws_iam_role {
    role_arn = aws_iam_role.storage_credential_role.arn
  }
  depends_on = [time_sleep.wait_30_seconds]
}

// External Location
resource "databricks_external_location" "data_example" {
  name            = "external-location-example"
  url             = "s3://${var.data_bucket}/"
  credential_name = databricks_storage_credential.external.id
  skip_validation = true
  read_only       = true
  comment         = "Managed by TF"
}

// External Location Grant
resource "databricks_grants" "data_example" {
  external_location = databricks_external_location.data_example.id
  grant {
    principal  = var.data_access
    privileges = ["ALL_PRIVILEGES"]
  }
}