variable "environment" {
  default = "prod"
}

variable "version" {
  default = 100
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
  default = "2"
}

variable "asg_desired" {
  description = "Min numbers of servers in ASG"
  default = "2"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default = "2"
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
  default = "2"
}

# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------


variable "elb_interval" {
    default = 10
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

module "prod_vpc" {
  source = "../../../modules/blended/template"
	environment =    "${var.environment}"
  cidr             = "172.20.0.0/16"
	az1_cidr_public  = "172.20.1.0/24"
	az2_cidr_public  = "172.20.2.0/24"
	az3_cidr_public  = "172.20.3.0/24"
	az1_cidr_private = "172.20.200.0/24"
	az2_cidr_private = "172.20.201.0/24"
	az3_cidr_private = "172.20.202.0/24"
  az1_rds          = "172.20.210.0/24"
  az2_rds          = "172.20.211.0/24"
  az3_rds          = "172.20.212.0/24"
  az1_elasticache  = "172.20.220.0/24"
  az2_elasticache  = "172.20.221.0/24"
  az3_elasticache  = "172.20.222.0/24"
  az1_nat_eip_id   = "${var.production_az1_nat_eip_id}"
  az2_nat_eip_id   = "${var.production_az2_nat_eip_id}"
  az3_nat_eip_id   = "${var.production_az3_nat_eip_id}"
  asg_min          = "${var.asg_min}"
  asg_max          = "${var.asg_max}"
  asg_desired      = "${var.asg_desired}"
  frontend_m_d_m   = "${var.frontend_m_d_m}"
  frontend_m_d_m_d = "${var.frontend_m_d_m_d}"
  instance_type    = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr     = "${var.bastion_cidr}"
  internal_whitelist   = "${var.prod_whitelist}"
  ssh_whitelist        = "${var.frontend_whitelist},${var.build_az1_nat_eip}"
  public_whitelist     = "0.0.0.0/0"
  pingdom1             = "${var.pingdom1}"
  pingdom2             = "${var.pingdom2}"
  pingdom3             = "${var.pingdom3}"
  nginx_path       = "../templates/nginx.tpl"
  node_path        = "../templates/node.tpl"
  java_path        = "../templates/java.tpl"
  mysql_path       = "../templates/mysql.tpl"
  bastion_path       = "../templates/bastion.tpl"

  aws_region       = "${var.aws_region}"
  route53_zone_id  = "${var.route53_zone_id}"

  rds_allocated_storage = 15
  rds_engine            = "mysql"
  rds_engine_version    = "5.7.11"
  rds_instance_class    = "db.t2.medium"
  rds_parameter_group_name          = "default.mysql5.7"
  multi_az              = true
  rds_username          = "${var.environment}"
  rds_password          = "${var.prod_rds}"

  aws_elasticache_cluster_node_type = "cache.m3.medium"
  aws_elasticache_cluster_engine    = "redis"
  aws_elasticache_cluster_num_cache_nodes  = 1
  aws_elasticache_cluster_parameter_group_name = "default.redis2.8"
  aws_elasticache_cluster_port      = 6379

  elb_interval          = "${var.elb_interval}"
  scale_down_size       = "${var.asg_desired}"
  scale_up_recurrence   = "0 0 * * 1" 
  scale_down_recurrence = "0 0 * * 6"


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
  ssl_certificate       = "arn:aws:acm:eu-west-1:050124427385:certificate/bc4ae00d-7cc5-4e95-b5a1-3575d6d382b8"
}