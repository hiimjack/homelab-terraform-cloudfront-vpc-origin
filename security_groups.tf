resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "default-disabled"
  }
}

resource "aws_security_group" "cf-to-alb" {
  name        = "${var.project_name}-cf-to-alb"
  description = "Accepts inbound traffic exclusively from Amazon CloudFront via the AWS-managed prefix list"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow inbound traffic from CloudFront"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "internal" {
  name        = "${var.project_name}-internal"
  description = "Allows internal communication between resources associated with this Security Group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all traffic from this security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
