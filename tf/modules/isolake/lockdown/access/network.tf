module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-workspace-lockdown-VPC"
  cidr = var.ws_ld_vpc_cidr_range
  azs  = var.ws_ld_availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_igw             = false

  intra_subnets      = var.ws_ld_private_subnets_cidr
  intra_subnet_names = [for az in var.ws_ld_availability_zones : format("%s-isolake-frontend-%s", var.resource_prefix, az)]

}

// SG
resource "aws_security_group" "sg" {

  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  tags = {
    Name = "${var.resource_prefix}-data-plane-sg"
  }
}