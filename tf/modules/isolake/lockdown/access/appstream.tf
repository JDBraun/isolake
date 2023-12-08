resource "aws_iam_role" "appstream_role" {
  name        = "isolake-appstream-role"
  description = "Role for the AppStream fleet"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "appstream.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_access" {
  name = "AllowSSMAccess"
  role = aws_iam_role.appstream_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_appstream_fleet" "appstream_fleet" {
  name = "${var.resource_prefix}-fleet"
  compute_capacity {
    desired_instances = 1
  }
  description                        = "Example fleet"
  fleet_type                         = "ON_DEMAND"
  idle_disconnect_timeout_in_seconds = 3600
  max_user_duration_in_seconds       = 3600
  disconnect_timeout_in_seconds      = 3600
  instance_type                      = "stream.standard.small"
  vpc_config {
    subnet_ids         = module.vpc.intra_subnets
    security_group_ids = tolist([aws_security_group.sg.id])
  }
  image_name = "Amazon-AppStream2-Sample-Image-03-11-2023"
}

resource "aws_appstream_stack" "appstream_stack" {
  name         = "${var.resource_prefix}-stack"
  description  = "AppStream stack for Data Sandbox"
  display_name = "AppStream Data Sandbox Stack"
  storage_connectors {
    connector_type = "HOMEFOLDERS"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
    permission = "DISABLED"
  }
  user_settings {
    action     = "FILE_DOWNLOAD"
    permission = "DISABLED"
  }
  user_settings {
    action     = "FILE_UPLOAD"
    permission = "DISABLED"
  }
  user_settings {
    action     = "PRINTING_TO_LOCAL_DEVICE"
    permission = "DISABLED"
  }
}

resource "aws_appstream_fleet_stack_association" "appstream_fleet_stack_association" {
  fleet_name = aws_appstream_fleet.appstream_fleet.name
  stack_name = aws_appstream_stack.appstream_stack.name
  depends_on = [aws_appstream_fleet.appstream_fleet, aws_appstream_stack.appstream_stack]
}