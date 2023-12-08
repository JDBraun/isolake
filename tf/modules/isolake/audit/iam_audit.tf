// IAM Role
// https://docs.databricks.com/en/administration-guide/account-settings-e2/audit-aws-credentials.html

// Assume Role Policy Log Delivery
data "databricks_aws_assume_role_policy" "log_delivery" {
  external_id      = var.databricks_account_id
  for_log_delivery = true
}

// Log Delivery IAM Role
resource "aws_iam_role" "log_delivery" {
  name               = "${var.resource_prefix}-log-delivery"
  description        = "(${var.resource_prefix}) Log Delivery Role"
  assume_role_policy = data.databricks_aws_assume_role_policy.log_delivery.json
  tags = {
    Name = "${var.resource_prefix}-log-delivery-role"
  }
}

# // The Sample IAM Policy for Log Delivery Role
data "aws_iam_policy_document" "log_delivery_policy" {
  statement {
    actions   = ["s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.log_delivery.id}"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.log_delivery.id}",
      "arn:aws:s3:::${aws_s3_bucket.log_delivery.id}/*"
    ]
    effect = "Allow"
  }
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "log_delivery_policy" {
  name   = "${var.resource_prefix}-log-delivery-policy"
  role   = aws_iam_role.log_delivery.id
  policy = data.aws_iam_policy_document.log_delivery_policy.json
}