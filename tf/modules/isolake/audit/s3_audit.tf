// S3 Log Bucket
resource "aws_s3_bucket" "log_delivery" {
  bucket        = "${var.resource_prefix}-log-delivery"
  force_destroy = true
  tags = {
    Name = "${var.resource_prefix}-log-delivery"
  }
}

// S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

// S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "log_delivery" {
  bucket                  = aws_s3_bucket.log_delivery.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.log_delivery]
}

// S3 Policy for Log Delivery Data
data "databricks_aws_bucket_policy" "log_delivery" {
  full_access_role = aws_iam_role.log_delivery.arn
  bucket           = aws_s3_bucket.log_delivery.bucket
}

// S3 Policy for Log Delivery Resources
resource "aws_s3_bucket_policy" "log_delivery" {
  bucket = aws_s3_bucket.log_delivery.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
        },
        "Action" : "s3:GetBucketLocation",
        "Resource" : "arn:aws:s3:::${var.resource_prefix}-log-delivery"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
        },
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.resource_prefix}-log-delivery",
          "arn:aws:s3:::${var.resource_prefix}-log-delivery/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${aws_iam_role.log_delivery.arn}"]
        },
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::${var.resource_prefix}-log-delivery"
      }
    ]
    }
  )
  depends_on = [
    aws_s3_bucket.log_delivery
  ]
}
