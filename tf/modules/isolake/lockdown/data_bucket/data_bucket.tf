// New Data bucket
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

resource "aws_s3_bucket" "isolake_data_bucket" {
  bucket        = var.data_bucket
  force_destroy = true
  tags = {
    Name = var.data_bucket
  }
}

resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.isolake_data_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "isolake_data_bucket" {
  bucket = aws_s3_bucket.isolake_data_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.isolake_data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.isolake_data_bucket]
}
// 
data "aws_iam_policy_document" "data_bucket_policy" {
  # # Prevent lock out during testing.
  # statement {
  #   sid     = "DenyAccessFromUntrustedNetworks"
  #   effect  = "Deny"
  #   actions = ["s3:*"]
  #   resources = [
  #     "arn:aws:s3:::${aws_s3_bucket.isolake_data_bucket.id}",
  #     "arn:aws:s3:::${aws_s3_bucket.isolake_data_bucket.id}/*"
  #   ]

  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }

  #   condition {
  #     test     = "NotIpAddressIfExists"
  #     variable = "aws:SourceIp"

  #     values = [
  #       var.system_ip
  #     ]
  #   }

  #   condition {
  #     test     = "StringNotEqualsIfExists"
  #     variable = "aws:SourceVpc"

  #     values = [
  #       var.vpc_id
  #     ]
  #   }
  # }

  # statement {
  #   sid     = "DenyActionsFromUntrustedPrincipals"
  #   effect  = "Deny"
  #   actions = ["s3:*"]
  #   resources = [
  #     "arn:aws:s3:::${aws_s3_bucket.isolake_data_bucket.id}",
  #     "arn:aws:s3:::${vaws_s3_bucket.isolake_data_bucket.id}/*"
  #   ]

  #   principals {
  #     type        = "AWS"
  #     identifiers = ["*"]
  #   }

  #   condition {
  #     test     = "StringNotEqualsIfExists"
  #     variable = "aws:PrincipalArn"

  #     values = [
  #       "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential",
  #       var.system_arn
  #     ]
  #   }
  # }

  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.data_bucket}",
      "arn:aws:s3:::${var.data_bucket}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "data_bucket_policy" {
  bucket     = aws_s3_bucket.isolake_data_bucket.id
  policy     = data.aws_iam_policy_document.data_bucket_policy.json
  depends_on = [time_sleep.wait_30_seconds]
}