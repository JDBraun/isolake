// PHZ
resource "aws_route53_zone" "private" {
  name = "cloud.databricks.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "rest_endpoint" {
  zone_id    = aws_route53_zone.private.id
  name       = replace(var.workspace_url, "https://", "")
  type       = "A"
  ttl        = "300"
  records    = [data.aws_network_interface.eni.private_ips[0]]
  depends_on = [aws_vpc_endpoint.frontend_rest]
}

resource "aws_route53_record" "dbc_endpoint" {
  zone_id    = aws_route53_zone.private.id
  name       = "dbc-dp-${var.workspace_id}.cloud.databricks.com"
  type       = "CNAME"
  ttl        = "300"
  records    = [replace(var.workspace_url, "https://", "")]
  depends_on = [aws_vpc_endpoint.frontend_rest]
}