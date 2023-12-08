variable "resource_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "databricks_account_id" {
  type = string
}

variable "databricks_workspace_id" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "control_plane_ip" {
  type = string
}

variable "ucname" {
  type = string
}

variable "system_ip" {
  type = string
}

variable "system_arn" {
  type = string
}

variable "restricted_uc_bucket_policy" {
  type = bool
}