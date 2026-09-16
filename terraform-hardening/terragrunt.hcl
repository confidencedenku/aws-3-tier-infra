include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "GIT_MODULE_URL//modules/aws-three-tier?ref=IMMUTABLE_TAG"
}

locals {
  environment = "hardening"
}

inputs = {
  assume_role_arn = "arn:aws:iam::HARDENING_ACCOUNT_ID:role/TERRAFORM_ROLE"
  environment     = local.environment
  name_prefix     = "${include.root.locals.project}-${local.environment}"

  vpc_cidr             = "HARDENING_VPC_CIDR"
  availability_zones   = ["AZ_1", "AZ_2", "AZ_3"]
  public_subnet_cidrs  = ["PUBLIC_SUBNET_1", "PUBLIC_SUBNET_2", "PUBLIC_SUBNET_3"]
  app_subnet_cidrs     = ["APP_SUBNET_1", "APP_SUBNET_2", "APP_SUBNET_3"]
  data_subnet_cidrs    = ["DATA_SUBNET_1", "DATA_SUBNET_2", "DATA_SUBNET_3"]

  enable_nat_gateway       = true
  one_nat_gateway_per_az   = true
  enable_vpc_flow_logs     = true
  flow_logs_retention_days = 90
  gateway_vpc_endpoints    = ["s3", "dynamodb"]
  interface_vpc_endpoints  = ["ecr.api", "ecr.dkr", "kms", "logs", "monitoring", "secretsmanager", "ssm", "ssmmessages", "ec2messages", "sts"]

  route53_zone_id       = "HARDENING_ROUTE53_ZONE_ID"
  application_fqdn     = "HARDENING_APP_FQDN"
  acm_certificate_arn  = "HARDENING_ACM_CERTIFICATE_ARN"
  alb_internal         = false
  alb_enable_http2     = true
  alb_enable_deletion_protection = true
  alb_access_logs_bucket         = "HARDENING_ALB_LOG_BUCKET"
  alb_health_check_path          = "/health"
  allowed_ingress_cidrs          = ["APPROVED_TEST_CIDR"]
  enable_waf                      = true
  waf_web_acl_arn                 = "HARDENING_WAF_ACL_ARN"

  app_ami_id               = "CIS_HARDENED_AMI_ID"
  app_instance_type        = "HARDENING_INSTANCE_TYPE"
  app_instance_profile_arn = "HARDENING_INSTANCE_PROFILE_ARN"
  app_min_size              = 3
  app_desired_capacity      = 3
  app_max_size              = 6
  app_target_cpu_percent    = 55
  app_health_check_type     = "ELB"
  app_enable_detailed_monitoring = true
  app_root_volume_kms_key_arn    = "HARDENING_EBS_KMS_KEY_ARN"
  app_secrets_manager_arns       = ["HARDENING_APP_SECRET_ARN"]
  require_imdsv2                 = true
  imds_hop_limit                 = 1
  enable_ssh                     = false

  database_engine             = "POSTGRES_OR_AURORA_POSTGRESQL"
  database_engine_version     = "ENGINE_VERSION"
  database_instance_class    = "HARDENING_DB_INSTANCE_CLASS"
  database_name              = "HARDENING_DATABASE_NAME"
  database_secret_arn        = "HARDENING_DATABASE_SECRET_ARN"
  database_multi_az          = true
  database_storage_encrypted = true
  database_kms_key_arn       = "HARDENING_RDS_KMS_KEY_ARN"
  database_backup_retention_days = 14
  database_deletion_protection    = true
  database_skip_final_snapshot    = false
  database_final_snapshot_identifier = "HARDENING_FINAL_SNAPSHOT_NAME"
  database_performance_insights_enabled = true
  database_iam_authentication_enabled    = true

  enable_cloudwatch_alarms = true
  alarm_sns_topic_arns     = ["HARDENING_ALARM_SNS_TOPIC_ARN"]
  log_retention_days       = 90
  enable_guardduty         = true
  enable_security_hub      = true
  enable_aws_config        = true

  tags = {
    Environment        = local.environment
    DataClassification = "confidential"
    SecurityBaseline   = "production-candidate"
  }
}
