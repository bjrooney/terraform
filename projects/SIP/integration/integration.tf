variable "environment" {
  default = "integration"
}

variable "version" {
  default = "50"
}

# --------------------------------------------------------------------------------------------
# -------------------------- Bastion Instance Type and AMI               ---------------------
# --------------------------------------------------------------------------------------------

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_ami" {
  default = "ami-c1b3e9b2"
}

# --------------------------------------------------------------------------------------------
# -------------------------- Java App Instance Types across all services ---------------------
# --------------------------------------------------------------------------------------------

variable "ami" {
  default = "ami-c1b3e9b2"
}

# --------------------------------------------------------------------------------------------
# -------------------------- Java Apps except Indexer and Dataloader--------------------------
# --------------------------------------------------------------------------------------------

variable "instance_type" {
  default = "m3.medium"
}

variable "spot_price" {
  default = 0.5
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_desired" {
  description = "Min numbers of servers in ASG"
  default = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "1"
}

# ----------------------------------------------------------------------------------------------
# --Java App Indexer and Dataloader (only ever a single instance) Instance Type and Spot Price--
# ----------------------------------------------------------------------------------------------

variable "indexer_dataloader_instance_type" {
  default = "m3.xlarge"
}

variable "indexer_dataloader_spot_price" {
  default = 3.5
}

# ------------------------------------------------------------------------------------------
# ----Node instance Info Max  Desired Min---------------------------------------------------
# ------------------------------------------------------------------------------------------

variable "node_ami" {
  default = "ami-c1b3e9b2"
}

variable "node_instance_type" {
  default = "m3.xlarge"
}

variable "node_spot_price" {
  default = 3.5
}

variable  "frontend_m_d_m" {
  default = "2"
}

variable  "frontend_m_d_m_d" {
  default = "0"
}

# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------


variable "elb_interval" {
    default = 30
}

# Specify the provider and access details
provider "aws" {
  region     = "${var.aws_region}"
  profile    = "tfgm"
}

data "terraform_remote_state" "remote_state" {
    backend        = "s3"
    config {
        bucket     = "terraform-tfgm"
        key        = "sip-${var.environment}/terraform.tfstate"
        region     = "${var.aws_region}"
        profile    = "tfgm"
    }
}

module "integration_vpc" {
  source = "../../../modules/spot/template"
  environment =    "${var.environment}"
  cidr             = "172.18.0.0/16"
  az1_cidr_public  = "172.18.1.0/24"
  az2_cidr_public  = "172.18.2.0/24"
  az3_cidr_public  = "172.18.3.0/24"
  az1_cidr_private = "172.18.200.0/24"
  az2_cidr_private = "172.18.201.0/24"
  az3_cidr_private = "172.18.202.0/24"
  az1_rds          = "172.18.210.0/24"
  az2_rds          = "172.18.211.0/24"
  az3_rds          = "172.18.212.0/24"
  az1_elasticache  = "172.18.220.0/24"
  az2_elasticache  = "172.18.221.0/24"
  az3_elasticache  = "172.18.222.0/24"
  az1_nat_eip_id   = "${var.integration_az1_nat_eip_id}"
  az2_nat_eip_id   = "${var.integration_az2_nat_eip_id}"
  az3_nat_eip_id   = "${var.integration_az3_nat_eip_id}"
  asg_min          = "${var.asg_min}"
  asg_max          = "${var.asg_max}"
  asg_desired      = "${var.asg_desired}"
  frontend_m_d_m   = "${var.frontend_m_d_m}"
  frontend_m_d_m_d = "${var.frontend_m_d_m_d}"
  instance_type    = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr     = "${var.bastion_cidr}"
  internal_whitelist = "${var.integration_whitelist}"
  ssh_whitelist        = "${var.tfgm_whitelist},${var.build_az1_nat_eip}"
  public_whitelist     = "${var.pete_smart},${var.tfgm_whitelist},${var.integration_az1_nat_eip},${var.integration_az2_nat_eip},${var.integration_az3_nat_eip},${var.build_az1_nat_eip}"
  pingdom1          = "${var.pingdom1}"
  pingdom2          = "${var.pingdom2}"
  pingdom3          = "${var.pingdom3}"
  nginx_path       = "../templates/nginx.tpl"
  node_path        = "../templates/node.tpl"
  java_path        = "../templates/java.tpl"
  mysql_path       = "../templates/mysql.tpl"
  bastion_path       = "../templates/bastion.tpl"
  
  rds_username     = "${var.environment}"
  rds_password     = "${var.integration_rds}"
  aws_region       = "${var.aws_region}"
  route53_zone_id  = "${var.route53_zone_id}"
  rds_allocated_storage = 15
  rds_engine            = "mysql"
  rds_engine_version    = "5.7.11"
  rds_instance_class    = "db.t2.medium"
  rds_parameter_group_name          = "default.mysql5.7"

  aws_elasticache_cluster_node_type = "cache.m3.medium"
  aws_elasticache_cluster_engine    = "Redis"
  aws_elasticache_cluster_num_cache_nodes  = 1
  aws_elasticache_cluster_parameter_group_name = "default.redis3.2"
  aws_elasticache_cluster_port      = 6379
  aws_elasticache_az_mode = true

  elb_interval         = "${var.elb_interval}"
  scale_down_size      = 0
  scale_up_recurrence   = "00  9 * * 1-5" 
  scale_down_recurrence = "30 17 * * *"
  multi_az = false


  node_ami              = "${var.node_ami}"
  node_instance_type    = "${var.node_instance_type}"
  node_spot_price       = "${var.node_spot_price}"

  ami                   = "${var.ami}"
  instance_type         = "${var.instance_type}"
  spot_price            = "${var.spot_price}"

  bastion_instance_type = "${var.bastion_instance_type}"
  bastion_ami           = "${var.bastion_ami}"

  indexer_dataloader_instance_type = "${var.indexer_dataloader_instance_type}"
  indexer_dataloader_spot_price    = "${var.indexer_dataloader_spot_price}"
  
  version               = "${var.version}"
  ssl_certificate = "arn:aws:acm:eu-west-1:050124427385:certificate/19019513-0adb-45c1-b369-35b07cd2b542"

}
