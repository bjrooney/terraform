variable "environment" {
  default = "qa"
}

variable "version" {
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
  default = "1"
}

variable  "frontend_m_d_m_d" {
  default = "0"
}

# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------

variable "elb_interval" {
    default = 300
}

variable "gazzer" {
  default = "213.205.192.194/32"
}

variable "ray_whitelist" {
  default = "82.37.106.236/32,84.93.121.196/32,31.48.196.1/32,86.158.10.44/32,82.132.243.160/32,86.147.0.159/32,92.233.231.173/32"
}

variable "open" {
  default = "0.0.0.0/0"
}

resource "aws_eip" "az1_nat_eip" {
  vpc = true
}

resource "aws_eip" "az2_nat_eip" {
  vpc = true
}

resource "aws_eip" "az3_nat_eip" {
  vpc = true
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

module "qa_vpc" {
	source = "../../../modules/spot_name_prefix/template"
	environment =    "${var.environment}"
  cidr             = "${var.qa_cidr}"
	az1_cidr_public  = "172.21.1.0/24"
	az2_cidr_public  = "172.21.2.0/24"
	az3_cidr_public  = "172.21.3.0/24"
	az1_cidr_private = "172.21.200.0/24"
	az2_cidr_private = "172.21.201.0/24"
	az3_cidr_private = "172.21.202.0/24"
  az1_rds          = "172.21.210.0/24"
  az2_rds          = "172.21.211.0/24"
  az3_rds          = "172.21.212.0/24"
  az1_elasticache  = "172.21.220.0/24"
  az2_elasticache  = "172.21.221.0/24"
  az3_elasticache  = "172.21.222.0/24"
  az1_nat_eip_id   = "${aws_eip.az1_nat_eip.id}"
  az2_nat_eip_id   = "${aws_eip.az2_nat_eip.id}"
  az3_nat_eip_id   = "${aws_eip.az3_nat_eip.id}"
  asg_min          = "${var.asg_min}"  
  asg_max          = "${var.asg_max}"
  asg_desired      = "${var.asg_desired}"
  frontend_m_d_m   = "${var.frontend_m_d_m}"
  frontend_m_d_m_d = "${var.frontend_m_d_m_d}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr         = "${var.bastion_cidr}"
  internal_whitelist   = "${var.qa_whitelist}"
  ssh_whitelist        = "${var.frontend_whitelist},${var.build_az1_nat_eip}"
  public_whitelist     = "${var.frontend_whitelist},${var.pete_smart},${aws_eip.az1_nat_eip.private_ip}/32,${aws_eip.az2_nat_eip.private_ip}/32,${aws_eip.az3_nat_eip.private_ip}/32,${var.build_az1_nat_eip}"
  pingdom1             = "${var.pingdom1}"
  pingdom2             = "${var.pingdom2}"
  pingdom3             = "${var.pingdom3}"
  nginx_path       = "../templates/nginx.tpl"
  node_path        = "../templates/node.tpl"
  java_path        = "../templates/java.tpl"
  mysql_path       = "../templates/mysql.tpl"
  bastion_path       = "../templates/bastion.tpl"
  rds_username     = "qa"
  rds_password     = "${var.qa_rds}"
  aws_region       = "${var.aws_region}"
  route53_zone_id  = "${var.route53_zone_id}"
  rds_allocated_storage = 15
  rds_engine            = "mysql"
  rds_engine_version    = "5.7.11"
  rds_instance_class    = "db.t2.medium"
  rds_parameter_group_name          = "default.mysql5.7"
  aws_elasticache_cluster_node_type = "cache.m3.medium"
  aws_elasticache_cluster_engine    = "redis"
  aws_elasticache_cluster_num_cache_nodes  = 1
  aws_elasticache_cluster_parameter_group_name = "default.redis3.2"
  aws_elasticache_cluster_port      = 6379
  aws_elasticache_az_mode = false
  elb_interval          = "${var.elb_interval}"
  scale_down_size       = 0
  scale_up_recurrence   = "0  7 * * 1-5" 
  scale_down_recurrence = "0 19 * * 1-5"
  multi_az              = false


  node_spot_price       = "${var.node_spot_price}"  
  node_ami              = "${var.node_ami}"
  node_instance_type    = "${var.node_instance_type}"

  ami                   = "${var.ami}"
  instance_type         = "${var.instance_type}"
  spot_price            = "${var.spot_price}"

  indexer_dataloader_instance_type = "${var.indexer_dataloader_instance_type}"
  indexer_dataloader_spot_price    = "${var.indexer_dataloader_spot_price}"

  bastion_instance_type = "${var.bastion_instance_type}"
  bastion_ami           = "${var.bastion_ami}"

  version               = "${var.version}"

  ssl_certificate = "arn:aws:acm:eu-west-1:050124427385:certificate/19019513-0adb-45c1-b369-35b07cd2b542"
}

