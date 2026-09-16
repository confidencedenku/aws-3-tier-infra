include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "GIT_MODULE_URL//modules/aws-three-tier?ref=IMMUTABLE_TAG"
}

locals {
  environment = "dev"
}

inputs = {
  assume_role_arn = "arn:aws:iam::DEV_ACCOUNT_ID:role/TERRAFORM_ROLE"
  environment     = local.environment
  name_prefix     = "${include.root.locals.project}-${local.environment}"

  vpc_cidr          = "DEV_VPC_CIDR"
  availability_zones = ["AZ_1", "AZ_2"]
  public_subnet_cidrs  = ["PUBLIC_SUBNET_1", "PUBLIC_SUBNET_2"]
  app_subnet_cidrs     = ["APP_SUBNET_1", "APP_SUBNET_2"]
  data_subnet_cidrs    = ["DATA_SUBNET_1", "DATA_SUBNET_2"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = false # Cost-conscious dev setting; prod uses one per AZ.
  enable_vpc_flow_logs   = true
  flow_logs_retention_days = 30
  gateway_vpc_endpoints  = ["s3", "dynamodb"]
  interface_vpc_endpoints = ["ecr.api", "ecr.dkr", "logs", "secretsmanager", "ssm", "ssmmessages", "ec2messages"]

  route53_zone_id       = "DEV_ROUTE53_ZONE_ID"
  application_fqdn     = "DEV_APP_FQDN"
  acm_certificate_arn  = "DEV_ACM_CERTIFICATE_ARN"
  alb_internal         = false
  alb_enable_http2     = true
  alb_enable_deletion_protection = false
  alb_access_logs_bucket         = "DEV_ALB_LOG_BUCKET"
  alb_health_check_path          = "/health"
  allowed_ingress_cidrs          = ["APPROVED_DEV_CIDR"]
  enable_waf                      = true
  waf_web_acl_arn                 = "DEV_WAF_ACL_ARN"

  app_ami_id               = "DEV_HARDENED_AMI_ID"
  app_instance_type        = "DEV_INSTANCE_TYPE"
  app_instance_profile_arn = "DEV_INSTANCE_PROFILE_ARN"
  app_min_size              = 2
  app_desired_capacity      = 2
  app_max_size              = 4
  app_target_cpu_percent    = 60
  app_health_check_type     = "ELB"
  app_enable_detailed_monitoring = true
  app_root_volume_kms_key_arn    = "DEV_EBS_KMS_KEY_ARN"
  app_secrets_manager_arns       = ["DEV_APP_SECRET_ARN"]

  database_engine             = "POSTGRES_OR_AURORA_POSTGRESQL"
  database_engine_version     = "ENGINE_VERSION"
  database_instance_class    = "DEV_DB_INSTANCE_CLASS"
  database_name              = "DEV_DATABASE_NAME"
  database_secret_arn        = "DEV_DATABASE_SECRET_ARN"
  database_multi_az          = true
  database_storage_encrypted = true
  database_kms_key_arn       = "DEV_RDS_KMS_KEY_ARN"
  database_backup_retention_days = 7
  database_deletion_protection    = false
  database_skip_final_snapshot    = true
  database_performance_insights_enabled = true

  enable_cloudwatch_alarms = true
  alarm_sns_topic_arns     = ["DEV_ALARM_SNS_TOPIC_ARN"]
  log_retention_days       = 30

  tags = {
    Environment        = local.environment
    DataClassification = "internal"
  }
}
