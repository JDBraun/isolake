// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

// Metastore
resource "databricks_metastore" "this" {
  name          = "unity-catalog-${var.resource_prefix}"
  storage_root  = "s3://${aws_s3_bucket.unity_catalog_bucket.id}/metastore"
  region        = var.region
  force_destroy = true
}

//Metastore root data storage
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.unity_catalog_role.id
  aws_iam_role {
    role_arn = aws_iam_role.unity_catalog_role.arn
  }
  is_default = true
  depends_on = [
    aws_iam_role.unity_catalog_role,
    time_sleep.wait_30_seconds
  ]
}