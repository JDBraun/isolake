// Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  bucket        = var.ucname
  force_destroy = true
  tags = {
    Name = var.ucname
  }
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  bucket = aws_s3_bucket.unity_catalog_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.unity_catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}

data "aws_iam_policy_document" "uc_bucket_policy_default" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.ucname}",
      "arn:aws:s3:::${var.ucname}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = ["false"]
    }
  }
}
data "aws_iam_policy_document" "uc_bucket_policy_restricted" {
  statement {
    sid     = "DenyAccessFromUntrustedNetworks"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.ucname}",
      "arn:aws:s3:::${var.ucname}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "NotIpAddressIfExists"
      variable = "aws:SourceIp"

      values = [
        var.control_plane_ip,
        var.system_ip
      ]
    }

    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:SourceVpc"

      values = [
        var.vpc_id
      ]
    }
  }

  statement {
    sid     = "DenyActionsFromUntrustedPrincipals"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.ucname}",
      "arn:aws:s3:::${var.ucname}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:PrincipalArn"

      values = [
        "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog",
        var.system_arn
      ]
    }
  }

  statement {
    sid     = "AllowSSLRequestsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.ucname}",
      "arn:aws:s3:::${var.ucname}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = ["false"]
    }
  }
}
resource "aws_s3_bucket_policy" "uc_bucket_policy" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  policy = var.restricted_uc_bucket_policy ? data.aws_iam_policy_document.uc_bucket_policy_restricted.json : data.aws_iam_policy_document.uc_bucket_policy_default.json
  depends_on = [aws_s3_bucket_public_access_block.unity_catalog, aws_s3_bucket_versioning.unity_catalog_versioning,
  aws_s3_bucket_public_access_block.unity_catalog, aws_s3_bucket_server_side_encryption_configuration.unity_catalog]
}