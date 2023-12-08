data "aws_prefix_list" "s3" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${var.region}.s3"]
  }
}

resource "aws_network_acl" "lockdown" {
  vpc_id = var.vpc_id
}

resource "aws_network_acl_rule" "vpc_ingress" {
  network_acl_id = aws_network_acl.lockdown.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_range # Assumes only one block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "vpc_egress" {
  network_acl_id = aws_network_acl.lockdown.id
  rule_number    = 200
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr_range # Assumes only one block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "s3_ingress" {
  count          = var.prefix_list_index
  network_acl_id = aws_network_acl.lockdown.id
  rule_number    = 101 + count.index
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = element(data.aws_prefix_list.s3.cidr_blocks, count.index)
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "s3_egress" {
  count          = var.prefix_list_index
  network_acl_id = aws_network_acl.lockdown.id
  rule_number    = 201 + count.index
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = element(data.aws_prefix_list.s3.cidr_blocks, count.index)
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_association" "lockdown" {
  count = length(var.subnets)

  subnet_id      = var.subnets[count.index]
  network_acl_id = aws_network_acl.lockdown.id

}