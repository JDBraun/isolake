module "isolake" {
  source = "./modules/isolake"
  providers = {
    databricks.mws = databricks.mws
    aws            = aws
  }

  // Authentication configuration for Databricks and AWS accounts
  databricks_account_id = var.databricks_account_id // Databricks account ID
  client_id             = var.client_id             // Databricks client ID for OAuth
  client_secret         = var.client_secret         // Databricks client secret for OAuth
  aws_account_id        = var.aws_account_id        // AWS account ID for integration

  // User identification and ownership variables
  resource_prefix = var.resource_prefix // Prefix for naming created resources
  resource_owner  = var.resource_owner  // Owner of the resources for tracking and management
  system_ip       = ""                  // System IP for administrative access and bucket policies
  system_arn      = ""                  // System ARN for bucket policies

  // AWS configuration and regional setup
  region           = var.region  // AWS region for resource deployment
  full_region_name = "nvirginia" // Full name of the region for restrictive DBFS bucket policies
  region_name      = "virginia"  // Short name of the region

  // Resource configuration for Isolake environment
  metastore_id         = null                           // Metastore ID - Leave NULL if no existing metastore
  dbfsname             = ""                             // S3 bucket name for the workspace root storage
  ucname               = ""                             // S3 bucket name for the Unity Catalog (UC) metastore
  data_bucket          = ""                             // Name of the existing data bucket
  data_access          = ""                             // Name of the user or entity that will be given read access to the data in UC
  vpc_cidr_range       = "10.0.0.0/23"                  // CIDR range for the VPC
  private_subnets_cidr = ["10.0.0.0/24", "10.0.1.0/24"] // CIDR blocks for private subnets
  availability_zones   = ["us-east-1a", "us-east-1b"]   // Availability zones for resource deployment
  sg_ingress_protocol  = ["tcp", "udp"]                 // Allowed protocols for within security group ingress
  sg_egress_protocol   = ["tcp", "udp"]                 // Allowed protocols for within security group egress

  // Optional frontend lockdown through AWS AppStream and PrivateLink
  enable_front_end_lockdown  = false           // Flag to enable frontend lockdown
  ws_ld_vpc_cidr_range       = "10.0.0.0/27"   // CIDR range for AppStream VPC
  ws_ld_private_subnets_cidr = ["10.0.0.0/28"] // CIDR for AppStream private subnets
  ws_ld_availability_zones   = ["us-east-1a"]  // Availability zone for AppStream

  // Region-specific configurations for Databricks and AWS services - https://docs.databricks.com/en/resources/supported-regions.html#control-plane-nat-and-storage-bucket-addresses
  control_plane_ip       = "54.156.226.103"                                          // IP for Databricks control plane
  workspace_vpce_service = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04" // VPCE service for workspace
  relay_vpce_service     = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf" // VPCE service for relay

  // Optional: Example cluster configuration with Derby Metastore
  enable_cluster_example = false // Flag to enable example cluster with Derby Metastore

  // Experimental features (WARNING: May impact usage or access)
  enable_dbfs_lockdown                  = false // Lockdown on workspace root bucket
  restricted_uc_bucket_policy           = false // Restrictive policy on Unity Catalog bucket
  enable_read_only_data_bucket_lockdown = false // Read-only lockdown on data bucket
  enable_nacl_lockdown                  = false // Lockdown on private subnet NACLs
}
