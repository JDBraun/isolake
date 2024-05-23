variable "aws_account_id" {
  description = "AWS account ID for integration"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for resource deployment"
  type        = list(string)
}

variable "client_id" {
  description = "Databricks client ID for OAuth"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Databricks client secret for OAuth"
  type        = string
  sensitive   = true
}

variable "control_plane_ip" {
  description = "IP for Databricks control plane"
  type        = string
}

variable "databricks_account_id" {
  description = "Databricks account ID"
  type        = string
  sensitive   = true
}

variable "data_access" {
  description = "Name of the user or entity that will be given read access to the data in UC"
  type        = string
}

variable "data_bucket" {
  description = "Name of the existing data bucket"
  type        = string
}

variable "dbfsname" {
  description = "S3 bucket name for the workspace root storage"
  type        = string
}

variable "enable_cluster_example" {
  description = "Flag to enable example cluster with Derby Metastore"
  type        = bool
}

variable "enable_dbfs_lockdown" {
  description = "Lockdown on workspace root bucket"
  type        = bool
}

variable "enable_front_end_lockdown" {
  description = "Flag to enable frontend lockdown"
  type        = bool
}

variable "enable_nacl_lockdown" {
  description = "Lockdown on private subnet NACLs"
  type        = bool
}

variable "enable_read_only_data_bucket_lockdown" {
  description = "Read-only lockdown on data bucket"
  type        = bool
}

variable "full_region_name" {
  description = "Full name of the region for restrictive DBFS bucket policies"
  type        = string
}

variable "metastore_id" {
  description = "Metastore ID if a regional metastore already exists"
  type        = string
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "region_name" {
  description = "Short name of the region"
  type        = string
}

variable "relay_vpce_service" {
  description = "VPCE service for relay"
  type        = string
}

variable "resource_owner" {
  description = "Owner of the resources for tracking and management"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for naming created resources"
  type        = string
}

variable "restricted_uc_bucket_policy" {
  description = "Restrictive policy on Unity Catalog bucket"
  type        = bool
}

variable "sg_egress_protocol" {
  description = "Allowed protocols for within security group egress"
  type        = list(string)
}

variable "sg_ingress_protocol" {
  description = "Allowed protocols for within security group ingress"
  type        = list(string)
}

variable "system_arn" {
  description = "System ARN for bucket policies"
  type        = string
}

variable "system_ip" {
  description = "System IP for administrative access and bucket policies"
  type        = string
}

variable "ucname" {
  description = "S3 bucket name for the Unity Catalog (UC) metastore"
  type        = string
}

variable "vpc_cidr_range" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "ws_ld_availability_zones" {
  description = "Availability zone for AppStream"
  type        = list(string)
}

variable "ws_ld_private_subnets_cidr" {
  description = "CIDR for AppStream private subnets"
  type        = list(string)
}

variable "ws_ld_vpc_cidr_range" {
  description = "CIDR range for AppStream VPC"
  type        = string
}

variable "workspace_vpce_service" {
  description = "VPCE service for workspace"
  type        = string
}

variable "workspace_level_tags" {
  description = "The custom tags key-value pairing that is attached to this workspace. "
  type        = map(string)
}