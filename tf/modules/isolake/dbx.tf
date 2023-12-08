// Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./workspace"
  providers = {
    databricks = databricks.mws
  }

  databricks_account_id       = var.databricks_account_id
  resource_prefix             = var.resource_prefix
  security_group_ids          = [aws_security_group.sg.id]
  subnet_ids                  = [module.vpc.intra_subnets[0], module.vpc.intra_subnets[1]]
  vpc_id                      = module.vpc.vpc_id
  cross_account_role_arn      = aws_iam_role.cross_account_role.arn
  bucket_name                 = aws_s3_bucket.root_storage_bucket.id
  region                      = var.region
  backend_rest                = aws_vpc_endpoint.backend_rest.id
  backend_relay               = aws_vpc_endpoint.backend_relay.id
  managed_storage_key         = aws_kms_key.managed_storage.arn
  workspace_storage_key       = aws_kms_key.workspace_storage.arn
  managed_storage_key_alias   = aws_kms_alias.managed_storage_key_alias.name
  workspace_storage_key_alias = aws_kms_alias.workspace_storage_key_alias.name
}

// Create Unity Catalog if not provided
module "uc_init" {
  count  = var.metastore_id == null ? 1 : 0
  source = "./uc_init"
  providers = {
    databricks = databricks.mws
    aws        = aws
  }

  resource_prefix             = var.resource_prefix
  ucname                      = var.ucname
  databricks_account_id       = var.databricks_account_id
  databricks_workspace_id     = module.databricks_mws_workspace.workspace_id
  aws_account_id              = var.aws_account_id
  control_plane_ip            = var.control_plane_ip
  vpc_id                      = module.vpc.vpc_id
  system_ip                   = var.system_ip
  system_arn                  = var.system_arn
  region                      = var.region
  restricted_uc_bucket_policy = var.restricted_uc_bucket_policy
  depends_on = [
    module.databricks_mws_workspace
  ]
}


// Assign Unity Catalog
module "uc_assignment" {
  source = "./uc_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id            = var.metastore_id != null ? var.metastore_id : module.uc_init[0].metastore_id
  databricks_workspace_id = module.databricks_mws_workspace.workspace_id
  depends_on = [
    module.databricks_mws_workspace
  ]
}


// Create Audit Logs
module "audit" {
  source = "./audit"
  providers = {
    databricks = databricks.mws
    aws        = aws
  }

  resource_prefix       = var.resource_prefix
  databricks_account_id = var.databricks_account_id

}

// Create Storage Credential & External Location
module "uc_data" {
  source = "./uc_data"
  providers = {
    databricks = databricks.created_workspace
    aws        = aws
  }

  resource_prefix       = var.resource_prefix
  data_bucket           = var.data_bucket
  data_access           = var.data_access
  databricks_account_id = var.databricks_account_id
  vpc_id                = module.vpc.vpc_id
  aws_account_id        = var.aws_account_id
  control_plane_ip      = var.control_plane_ip
  depends_on = [
    module.uc_init, module.uc_assignment
  ]
}

// Create Cluster with Derby Configuration
module "databricks_cluster" {
  count  = var.enable_cluster_example ? 1 : 0
  source = "./cluster"
  providers = {
    databricks = databricks.created_workspace
  }
}