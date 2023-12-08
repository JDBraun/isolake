# S3 Endpoint Policy
data "aws_iam_policy_document" "s3_vpc_endpoint_policy" {
  statement {
    sid    = "Grant access to Databricks Root Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.dbfsname}/*",
      "arn:aws:s3:::${var.dbfsname}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:SourceVpc"
      values = [
        module.vpc.vpc_id
      ]
    }
  }

  statement {
    sid    = "Grant access to Databricks Unity Catalog Metastore Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.ucname}/*",
      "arn:aws:s3:::${var.ucname}"
    ]
  }

  statement {
    sid    = "Grant read-only access to Data Bucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::${var.data_bucket}/*",
      "arn:aws:s3:::${var.data_bucket}"
    ]
  }

  statement {
    sid    = "Grant Databricks Read Access to Artifact and Data Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:GetObject",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}/*",
      "arn:aws:s3:::databricks-prod-artifacts-${var.region}",
      "arn:aws:s3:::databricks-datasets-${var.region_name}/*",
      "arn:aws:s3:::databricks-datasets-${var.region_name}"
    ]
  }

  statement {
    sid    = "Grant access to Databricks Log Bucket"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "arn:aws:s3:::databricks-prod-storage-${var.region_name}/*",
      "arn:aws:s3:::databricks-prod-storage-${var.region_name}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = ["414351767826"]
    }
  }
}

# STS Endpoint Policy
data "aws_iam_policy_document" "sts_vpc_endpoint_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetAccessKeyInfo",
      "sts:GetSessionToken",
      "sts:DecodeAuthorizationMessage",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["${var.aws_account_id}"]
    }
  }

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:GetSessionToken",
      "sts:TagSession"
    ]
    effect    = "Allow"
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::414351767826:user/databricks-datasets-readonly-user",
        "414351767826"
      ]
    }
  }
}

# Kinesis Endpoint Policy
data "aws_iam_policy_document" "kinesis_vpc_endpoint_policy" {
  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:DescribeStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:kinesis:${var.region}:414351767826:stream/*"]

    principals {
      type        = "AWS"
      identifiers = ["414351767826"]
    }
  }
}


// VPC Gateway Endpoint for S3, Interface Endpoint for Kinesis, and Interface Endpoint for STS
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.sg.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.intra_route_table_ids
      policy          = data.aws_iam_policy_document.s3_vpc_endpoint_policy.json
      tags = {
        Name = "${var.resource_prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      policy              = data.aws_iam_policy_document.sts_vpc_endpoint_policy.json
      subnet_ids = [
        module.vpc.intra_subnets[0],
        module.vpc.intra_subnets[1]
      ]
      tags = {
        Name = "${var.resource_prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      policy              = data.aws_iam_policy_document.kinesis_vpc_endpoint_policy.json
      subnet_ids = [
        module.vpc.intra_subnets[0],
        module.vpc.intra_subnets[1]
      ]
      tags = {
        Name = "${var.resource_prefix}-kinesis-vpc-endpoint"
      }
    }
  }
  depends_on = [
    module.vpc
  ]
}

// Databricks REST API endpoint
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id             = module.vpc.vpc_id
  service_name       = var.workspace_vpce_service
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0],
    module.vpc.intra_subnets[1]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-rest"
  }
}

// Databricks SCC endpoint
resource "aws_vpc_endpoint" "backend_relay" {
  vpc_id             = module.vpc.vpc_id
  service_name       = var.relay_vpce_service
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0],
    module.vpc.intra_subnets[1]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-backend-relay"
  }
}