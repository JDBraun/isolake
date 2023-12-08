// Frontend REST VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "frontend_access" {
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.frontend_rest.id
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-frontend-${module.vpc.vpc_id}"
  region              = var.region
}

// Private Access Setting Configuration
resource "databricks_mws_private_access_settings" "pas_lockdown" {
  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.resource_prefix}-PAS-lockdown"
  region                       = var.region
  public_access_enabled        = false
  private_access_level         = "ENDPOINT"
  allowed_vpc_endpoint_ids     = [databricks_mws_vpc_endpoint.frontend_access.vpc_endpoint_id]
  depends_on                   = [databricks_mws_vpc_endpoint.frontend_access]
}