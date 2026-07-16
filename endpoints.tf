resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.private-a.id,
    aws_route_table.private-b.id,
    aws_route_table.private-c.id
  ]

  tags = {
    Name = "${var.project_name}-vpce-s3"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each          = toset(local.interface_endpoints)
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private-a.id,
    aws_subnet.private-b.id,
    aws_subnet.private-c.id
  ]
  security_group_ids  = [aws_security_group.internal.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-vpce-${each.value}"
  }
}
