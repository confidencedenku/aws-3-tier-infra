include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "GIT_MODULE_URL//modules/aws-three-tier?ref=IMMUTABLE_RELEASE_TAG_OR_COMMIT"
}

locals {
  environment = "secure-prod"
}

inputs = {
  assume_role_arn = "arn:aws:iam::PROD_ACCOUNT_ID:role/TERRAFORM_ROLE"
  environment     = local.environment
  name_prefix     = "${include.root.locals.project}-${local.environment}"

  vpc_cidr             = "PROD_VPC_CIDR"
  availability_zones   = ["AZ_1", "AZ_2", "AZ_3"]
  public_subnet_cidrs  = ["PUBLIC_SUBNET_1", "PUBLIC_SUBNET_2", "PUBLIC_SUBNET_3"]
  app_subnet_cidrs     = ["APP_SUBNET_1", "APP_SUBNET_2", "APP_SUBNET_3"]
  data_subnet_cidrs    = ["DATA_SUBNET_1", "DATA_SUBNET_2", "DATA_SUBNET_3"]

  enable_nat_gateway       = true
  one_nat_gateway_per_az   = true
  enable_vpc_flow_logs     = true
  flow_logs_retention_days = 365
  gateway_vpc_endpoints    = ["s3", "dynamodb"]
  interface_vpc_endpoints  = ["ecr.api", "ecr.dkr", "kms", "logs", "monitoring", "secretsmanager", "ssm", "ec2messages", "sts"]

  route53_zone_id       = "PROD_ROUTE53_ZONE_ID"
  application_fqdn     = "PROD_APP_FQDN"
  acm_certificate_arn  = "PROD_ACM_CERTIFICATE_ARN"
  alb_internal         = false
  alb_enable_http2     = true
  alb_enable_deletion_protection = true
  alb_access_logs_bucket         = "PROD_ALB_LOG_BUCKET"
  alb_health_check_path          = "/health"
  allowed_ingress_cidrs          = ["0.0.0.0/0"] # HTTPS reaches WAF/ALB; app and data SGs remain private.
  enable_cloudfront              = true
  cloudfront_log_bucket          = "PROD_CLOUDFRONT_LOG_BUCKET"
  enable_waf                      = true
  waf_web_acl_arn                 = "PROD_WAF_ACL_ARN"

  app_ami_id               = "CIS_HARDENED_PROD_AMI_ID"
  app_instance_type        = "PROD_INSTANCE_TYPE"
  app_instance_profile_arn = "PROD_INSTANCE_PROFILE_ARN"
  app_min_size              = 3
  app_desired_capacity      = 6
  app_max_size              = 18
  app_target_cpu_percent    = 50
  app_health_check_type     = "ELB"
  app_enable_detailed_monitoring = true
  app_root_volume_kms_key_arn    = "PROD_EBS_KMS_KEY_ARN"
  app_secrets_manager_arns       = ["PROD_APP_SECRET_ARN"]
  require_imdsv2                 = true
  imds_hop_limit                 = 1
  enable_ssh                     = false
  enable_instance_refresh        = true
  instance_refresh_min_healthy_percentage = 90

  database_engine             = "AURORA_POSTGRESQL"
  database_engine_version     = "ENGINE_VERSION"
  database_instance_class    = "PROD_DB_INSTANCE_CLASS"
  database_name              = "PROD_DATABASE_NAME"
  database_secret_arn        = "PROD_DATABASE_SECRET_ARN"
  database_multi_az          = true
  database_reader_count      = 2
  database_storage_encrypted = true
  database_kms_key_arn       = "PROD_RDS_KMS_KEY_ARN"
  database_backup_retention_days = 35
  database_deletion_protection    = true
  database_skip_final_snapshot    = false
  database_final_snapshot_identifier = "PROD_FINAL_SNAPSHOT_NAME"
  database_performance_insights_enabled = true
  database_iam_authentication_enabled    = true
  database_enable_global_cluster         = false

  enable_cloudwatch_alarms = true
  alarm_sns_topic_arns     = ["PROD_PAGER_SNS_TOPIC_ARN", "PROD_SECURITY_SNS_TOPIC_ARN"]
  log_retention_days       = 365
  enable_guardduty         = true
  enable_security_hub      = true
  enable_aws_config        = true
  enable_inspector         = true
  enable_cloudtrail        = true
  cloudtrail_kms_key_arn   = "PROD_CLOUDTRAIL_KMS_KEY_ARN"
  cloudtrail_log_bucket    = "PROD_CLOUDTRAIL_LOG_BUCKET"

  backup_vault_name         = "PROD_BACKUP_VAULT"
  backup_vault_kms_key_arn  = "PROD_BACKUP_KMS_KEY_ARN"
  backup_cross_region_copy_destination_arn = "DR_BACKUP_VAULT_ARN"
  recovery_point_retention_days            = 365

  tags = {
    Environment        = local.environment
    DataClassification = "restricted"
    SecurityBaseline   = "production"
    Criticality        = "tier-1"
  }
}
