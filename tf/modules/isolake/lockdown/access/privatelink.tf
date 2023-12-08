// Databricks REST API endpoint
resource "aws_vpc_endpoint" "frontend_rest" {
  vpc_id             = module.vpc.vpc_id
  service_name       = var.workspace_vpce_service
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-databricks-frontend-rest"
  }
}

data "aws_network_interface" "eni" {
  depends_on = [aws_vpc_endpoint.frontend_rest]
  id         = tolist(aws_vpc_endpoint.frontend_rest.network_interface_ids)[0]
}

// All Required SSM Endpoints: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-privatelink.html

// SSM Endpoint
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-ssm-endpoint"
  }
}

// SSM Messages Endpoint
resource "aws_vpc_endpoint" "ssm_message_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-ssm-messages-endpoint"
  }
}


// EC2 Messages Endpoint
resource "aws_vpc_endpoint" "ec2_message_endpoint" {
  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [
    module.vpc.intra_subnets[0]
  ]
  private_dns_enabled = true
  depends_on          = [module.vpc.vpc_id]
  tags = {
    Name = "${var.resource_prefix}-ec2-messages-endpoint"
  }
}

