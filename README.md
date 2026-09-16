# Three-tier AWS Terragrunt environments

This bundle configures one reusable Terraform module for three isolated AWS environments:

- `terraform-dev`
- `terraform-hardening`
- `terraform-secure-prod`

The referenced Terraform module is expected to build a highly available three-tier platform across three Availability Zones:

1. Public tier: Route 53, CloudFront/WAF (where enabled), an internet-facing ALB, and public subnets containing only load balancers and NAT gateways.
2. Application tier: private subnets, an Auto Scaling Group, internal security groups, and private service endpoints.
3. Data tier: isolated database subnets, Multi-AZ RDS/Aurora, encryption, backups, and no direct internet route.


The files intentionally contain no database passwords. Pass secret ARNs to the module and retrieve values from AWS Secrets Manager at runtime.

## Expected Terraform module interface

The module referenced by `terraform.source` should declare variables matching the `inputs` maps in these configurations. It should create or accept all AWS resources described by those inputs. Keep application and database resources private; use SSM Session Manager instead of bastion-host SSH.

## Build will be automated using Jenkins to run terraform

## Use below only for validating terraform locally

```bash
terragrunt hcl fmt --check
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Use separate AWS accounts for dev, hardening, and production. The example `assume_role_arn` values enforce that boundary.