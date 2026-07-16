resource "aws_cloudfront_vpc_origin" "alb" {
  vpc_origin_endpoint_config {
    name                   = "${var.project_name}-alb-origin"
    arn                    = aws_lb.internal.arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      quantity = 1
      items    = ["TLSv1.2"]
    }
  }

  tags = {
    Name = "${var.project_name}-alb-vpc-origin"
  }
}

resource "aws_cloudfront_distribution" "nginx" {
  enabled = true
  comment = "${var.project_name} - distribution exposing the internal ALB via VPC Origin"



  origin {
    origin_id   = "internal-alb"
    domain_name = aws_lb.internal.dns_name

    custom_header {
      name  = local.custom-header-name
      value = random_password.custom-header-value.result
    }

    vpc_origin_config {
      vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "internal-alb"
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = data.aws_cloudfront_cache_policy.Managed-CachingDisabled.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cf-distribution"
  }
}
