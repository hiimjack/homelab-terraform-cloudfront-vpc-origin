# homelab-terraform-cloudfront-vpc-origin

Terraform script that exposes a private homelab service to the internet through Amazon CloudFront using a **VPC Origin**, avoiding a public-facing ALB or NAT gateway.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install)
- AWS credentials

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Name           | Description          | Default             |
| -------------- | -------------------- | ------------------- |
| `aws_region`   | AWS region           | `eu-west-1`         |
| `project_name` | Resource name prefix | `private-resources` |

## License

See [LICENSE](./LICENSE).
