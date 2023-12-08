// Lockdown DBFS
module "lockdown_dbfs" {
  count  = var.enable_dbfs_lockdown ? 1 : 0
  source = "./lockdown/dbfs"
  providers = {
    aws = aws
  }

  aws_account_id   = var.aws_account_id
  full_region_name = var.full_region_name
  dbfsname         = var.dbfsname
  dbfsid           = aws_s3_bucket.root_storage_bucket.id
  workspace_id     = module.databricks_mws_workspace.workspace_id
  vpc_id           = module.vpc.vpc_id
  control_plane_ip = var.control_plane_ip
  resource_prefix  = var.resource_prefix

  depends_on = [module.databricks_mws_workspace]
}

// Lockdown NACLs
module "lockdown_nacls" {
  count  = var.enable_nacl_lockdown ? 1 : 0
  source = "./lockdown/nacls"
  providers = {
    aws = aws
  }

  prefix_list_index = length(data.aws_prefix_list.s3.cidr_blocks)
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_range    = var.vpc_cidr_range
  subnets           = [module.vpc.intra_subnets[0], module.vpc.intra_subnets[1]]

  depends_on = [module.databricks_mws_workspace]
}

// Lockdown Workspace Access with a VM
module "lockdown_access" {
  count  = var.enable_front_end_lockdown ? 1 : 0
  source = "./lockdown/access"
  providers = {
    databricks = databricks.mws
    aws        = aws
  }

  region                                   = var.region
  databricks_account_id                    = var.databricks_account_id
  resource_prefix                          = var.resource_prefix
  ws_ld_vpc_cidr_range                     = var.ws_ld_vpc_cidr_range
  ws_ld_private_subnets_cidr               = var.ws_ld_private_subnets_cidr
  ws_ld_availability_zones                 = var.ws_ld_availability_zones
  workspace_url                            = module.databricks_mws_workspace.workspace_url
  workspace_id                             = module.databricks_mws_workspace.workspace_id
  workspace_vpce_service                   = var.workspace_vpce_service
  sg_egress_protocol                       = var.sg_egress_protocol
  sg_ingress_protocol                      = var.sg_ingress_protocol
  credential_configuration                 = module.databricks_mws_workspace.credential_configuration
  storage_configuration                    = module.databricks_mws_workspace.storage_configuration
  network_configuration                    = module.databricks_mws_workspace.network_configuration
  managed_services_customer_managed_key_id = module.databricks_mws_workspace.managed_services_customer_managed_key_id
  storage_customer_managed_key_id          = module.databricks_mws_workspace.storage_customer_managed_key_id

}

// Lockdown data bucket policy
module "lockdown_data_bucket" {
  count  = var.enable_read_only_data_bucket_lockdown ? 1 : 0
  source = "./lockdown/data_bucket"
  providers = {
    aws = aws
  }
  data_bucket     = var.data_bucket
  resource_prefix = var.resource_prefix
  vpc_id          = module.vpc.vpc_id
  aws_account_id  = var.aws_account_id
  system_ip       = var.system_ip
  system_arn      = var.system_arn

  depends_on = [module.databricks_mws_workspace]
}
