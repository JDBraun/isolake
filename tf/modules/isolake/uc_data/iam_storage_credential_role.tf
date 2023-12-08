// Storage Credential Trust Policy
data "aws_iam_policy_document" "passrole_for_storage_credential" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Storage Credential Role
resource "aws_iam_role" "storage_credential_role" {
  name               = "${var.resource_prefix}-storage-credential"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_storage_credential.json
  tags = {
    Name = "${var.resource_prefix}-storage_credential_role"
  }
}

data "aws_iam_policy_document" "storage_credential_iam_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.data_bucket}/*",
      "arn:aws:s3:::${var.data_bucket}"
    ]

    effect = "Allow"

    condition {
      test     = "IpAddressIfExists"
      variable = "aws:SourceIp"

      values = [
        var.control_plane_ip
      ]
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:SourceVpc"

      values = [
        var.vpc_id
      ]
    }
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-storage-credential"]
    effect    = "Allow"
  }
}


// Storage Credential Policy
resource "aws_iam_role_policy" "storage_credential_policy" {
  name   = "${var.resource_prefix}-storage-credential-policy"
  role   = aws_iam_role.storage_credential_role.id
  policy = data.aws_iam_policy_document.storage_credential_iam_policy.json
}