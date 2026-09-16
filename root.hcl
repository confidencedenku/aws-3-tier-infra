locals {
  project     = "PROJECT"
  aws_region  = "AWS_REGION"
  owner       = "PLATFORM_TEAM"
  cost_center = "COST_CENTER"
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "TERRAFORM_STATE_BUCKET"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    kms_key_id     = "STATE_KMS_KEY_ARN"
    dynamodb_table = "TERRAFORM_LOCK_TABLE"

    s3_bucket_tags = {
      Project   = local.project
      ManagedBy = "Terragrunt"
    }
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7.0, < 2.0.0"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 6.0"
        }
      }
    }

    provider "aws" {
      region = "${local.aws_region}"

      assume_role {
        role_arn     = var.assume_role_arn
        session_name = "terragrunt-${local.project}"
      }

      default_tags {
        tags = {
          Project    = "${local.project}"
          Owner      = "${local.owner}"
          CostCenter = "${local.cost_center}"
          ManagedBy  = "Terraform"
        }
      }
    }
  EOF
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    env_vars = {
      TF_IN_AUTOMATION = "true"
    }
  }
}
