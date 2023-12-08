
// Unity Catalog Trust Policy
data "aws_iam_policy_document" "passrole_for_unity_catalog" {
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
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Unity Catalog Role
resource "aws_iam_role" "unity_catalog_role" {
  name               = "${var.resource_prefix}-unity-catalog"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_unity_catalog.json
  tags = {
    Name = "${var.resource_prefix}-unity-catalog"
  }
}

// Unity Catalog IAM Policy
data "aws_iam_policy_document" "unity_catalog_iam_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.ucname}/*",
      "arn:aws:s3:::${var.ucname}"
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
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog"]
    effect    = "Allow"
  }
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-unity-catalog-policy"
  role   = aws_iam_role.unity_catalog_role.id
  policy = data.aws_iam_policy_document.unity_catalog_iam_policy.json
}