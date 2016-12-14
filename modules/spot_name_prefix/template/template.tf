variable "environment" {
}

variable "cidr" {
}

variable "az1_cidr_public" {
}
variable "az2_cidr_public" {
}
variable "az3_cidr_public" {
}

variable "az1_cidr_private" {
}
variable "az2_cidr_private" {
}
variable "az3_cidr_private" {
}

variable "az1_rds" {
}
variable "az2_rds" {
}
variable "az3_rds" {
}

variable "az1_elasticache" {
}
variable "az2_elasticache" {
}
variable "az3_elasticache" {
}

variable "az1_nat_eip_id" {
}
variable "az2_nat_eip_id" {
}
variable "az3_nat_eip_id" {
}

variable "instance_type" {
  description = "AWS instance type"
}

variable "iam_instance_profile" {
}

variable "bastion_cidr" {  
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"

}

variable "asg_max" {
  description = "Max numbers of servers in ASG"

}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"

}

variable "ssh_whitelist" {
  
}


variable "ami" {
}

variable "internal_whitelist" {
}

variable "public_whitelist" {
}

variable "key_name" {
  default = "green"
  description = "Name of AWS key pair"
}

variable "nginx_path" {

}

variable "node_path" {

}

variable "java_path" {

}

variable "mysql_path" {

}

variable "bastion_path" {

}

variable "rds_username" {

}

variable "rds_password" {
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "route53_zone_id" {

}

variable "rds_allocated_storage" {
}

variable "rds_engine" {
}

variable "rds_engine_version" {
}

variable "rds_instance_class" {
}

variable "rds_parameter_group_name" {
}


variable "aws_elasticache_cluster_node_type" {
}

variable "aws_elasticache_cluster_engine" {
}

variable "aws_elasticache_cluster_num_cache_nodes" {
}

variable "aws_elasticache_cluster_parameter_group_name" {
}

variable "aws_elasticache_cluster_port" {
}

variable "aws_elasticache_az_mode" {
  default = false
}

variable "node_ami" {

}

variable "elb_interval" {
    default = 5
}

variable "scale_down_size" {

}

variable "scale_up_recurrence" {

}

variable "scale_down_recurrence" {

}

variable "multi_az" {
  
}

variable "indexer_dataloader_instance_type" {

}

variable "indexer_dataloader_spot_price" {

}

variable "node_instance_type" {

}

variable "node_spot_price" {

}

variable "spot_price" {

}

variable "bastion_instance_type" {

}

variable "bastion_ami" {
}

variable "version" {

}

variable "pingdom1" {
}

variable "pingdom2" {
}

variable "pingdom3" {
}

variable  "frontend_m_d_m" {
}

variable  "frontend_m_d_m_d" {
}

variable "ssl_certificate" {
}




# Template for initial configuration bash script
data "template_file" "nginx" {
    template = "${file("${var.nginx_path}")}"
}

# Template for initial configuration bash script
data "template_file" "node" {
    template = "${file("${var.node_path}")}"
}

# Template for initial configuration bash script
data "template_file" "java" {
    template = "${file("${var.java_path}")}"
}

data "template_file" "mysql" {
    template = "${file("${var.mysql_path}")}"
}

module "vpc" {
  source = "../../vpc"
  environment = "${var.environment}"
  service = "vpc"
  cidr             = "${var.cidr}"
  az1_cidr_public  = "${var.az1_cidr_public}"
  az2_cidr_public  = "${var.az2_cidr_public}"
  az3_cidr_public  = "${var.az3_cidr_public}"
  az1_cidr_private = "${var.az1_cidr_private}"
  az2_cidr_private = "${var.az2_cidr_private}"
  az3_cidr_private = "${var.az3_cidr_private}"
  az1_rds          = "${var.az1_rds}"
  az2_rds          = "${var.az2_rds}"
  az3_rds          = "${var.az3_rds}"
  az1_elasticache  = "${var.az1_elasticache}"
  az2_elasticache  = "${var.az2_elasticache}"
  az3_elasticache  = "${var.az3_elasticache}"
  az1_nat_eip_id   = "${var.az1_nat_eip_id}"
  az2_nat_eip_id   = "${var.az2_nat_eip_id}"
  az3_nat_eip_id   = "${var.az3_nat_eip_id}"
  whitelist        = "${var.ssh_whitelist}"
}

resource "aws_eip" "bastion" {
  vpc = true
}

# Template for initial configuration bash script
data "template_file" "bastion" {
    template = "${file("${var.bastion_path}")}"
    vars {
      BASTION_EIP_ID = "${aws_eip.bastion.id}"
    }
}

module "bastion_asg" {
  source = "../../instance"
  environment = "${var.environment}"
  service = "bastion"
  region = "${var.aws_region}"
  instance_type = "${var.bastion_instance_type}"
  ami = "${var.bastion_ami}"
  user_data = "${data.template_file.bastion.rendered}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_public_id}"
  az2_id = "${module.vpc.az2_cidr_public_id}"
  az3_id = "${module.vpc.az3_cidr_public_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_group = "${module.vpc.aws_security_group_peering_id}"
  keyname = "${var.key_name}"
  subnet_id = "${module.vpc.az1_cidr_public_id}"
}

resource "aws_route53_record" "bastion" {
   zone_id = "${var.route53_zone_id}"
   name = "bastion.${var.environment}."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${aws_eip.bastion.public_ip}"]
}

module "frontend" {
  source = "../asg_frontend"
  environment = "${var.environment}"
  service = "frontend"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_public_id}"
  az2_id = "${module.vpc.az2_cidr_public_id}"
  az3_id = "${module.vpc.az3_cidr_public_id}"
  user_data = "${data.template_file.nginx.rendered}"
  asg_min =     "${var.frontend_m_d_m}"
  asg_max =     "${var.frontend_m_d_m}"
  asg_desired = "${var.frontend_m_d_m}"
  internal = false
  service_port = 80
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"
  elb_whitelist = "${var.public_whitelist}"
  pingdom1          = "${var.pingdom1}"
  pingdom2          = "${var.pingdom2}"
  pingdom3          = "${var.pingdom3}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.frontend_m_d_m_d}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version    = "${var.version}"
  ssl_certificate       = "${var.ssl_certificate}"
}

module "web" {
  source = "../asg"
  environment = "${var.environment}"
  service = "web"
  image_id = "${var.node_ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.node.rendered}"
  asg_min =     "${var.frontend_m_d_m}"
  asg_max =     "${var.frontend_m_d_m}"
  asg_desired = "${var.frontend_m_d_m}"
  internal = true
  service_port = 3001
  health_port  = 3002
  instance_type = "${var.node_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.frontend_m_d_m_d}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.node_spot_price}"
  version          = "${var.version}"
}

module "content" {
  source = "../asg"
  environment = "${var.environment}"
  service = "content"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "ticketandpass" {
  source = "../asg"
  environment = "${var.environment}"
  service = "ticketandpass"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "stations" {
  source = "../asg"
  environment = "${var.environment}"
  service = "stations"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "nationalrail" {
  source = "../asg"
  environment = "${var.environment}"
  service = "nationalrail"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}


module "tfgmmetrolink" {
  source = "../asg"
  environment = "${var.environment}"
  service = "tfgmmetrolink"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "networkimpacts" {
  source = "../asg"
  environment = "${var.environment}"
  service = "networkimpacts"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}"  
  elb_whitelist = "${var.cidr}"
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "bus" {
  source = "../asg"
  environment = "${var.environment}"
  service = "bus"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}" 
  elb_whitelist = "${var.cidr}" 
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "indexer" {
  source = "../asg"
  environment = "${var.environment}"
  service = "indexer"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.indexer_dataloader_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}" 
  elb_whitelist = "${var.cidr}" 
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.indexer_dataloader_spot_price}"
  version          = "${var.version}"
}


module "events" {
  source = "../asg"
  environment = "${var.environment}"
  service = "events"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.java.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 8080
  health_port  = 8081
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}" 
  elb_whitelist = "${var.cidr}" 
  elb_interval = "${var.elb_interval}"
  scale_down_size="${var.scale_down_size}"
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "scheduler" {
  source = "../asg"
  environment = "${var.environment}"
  service = "scheduler"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.nginx.rendered}"
  asg_min     = 1
  asg_max     = 1
  asg_desired = 1
  internal = true
  service_port = 80
  health_port  = 81
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}" 
  elb_whitelist = "${var.cidr}" 
  elb_interval = "${var.elb_interval}"
  scale_down_size = 1
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.spot_price}"
  version          = "${var.version}"
}

module "dataloader" {
  source = "../asg"
  environment = "${var.environment}"
  service = "dataloader"
  image_id = "${var.ami}"
  vpc_id = "${module.vpc.aws_vpc_id}"
  az1_id = "${module.vpc.az1_cidr_private_id}"
  az2_id = "${module.vpc.az2_cidr_private_id}"
  az3_id = "${module.vpc.az3_cidr_private_id}"
  user_data = "${data.template_file.mysql.rendered}"
  asg_min = 1
  asg_max = 1
  asg_desired = 1
  internal = true
  service_port = 80
  health_port  = 81
  instance_type = "${var.indexer_dataloader_instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.internal_whitelist}" 
  elb_whitelist = "${var.cidr}" 
  elb_interval = "${var.elb_interval}"
  scale_down_size = 1
  scale_down_recurrence="${var.scale_down_recurrence}"
  scale_up_recurrence="${var.scale_up_recurrence}"
  spot_price = "${var.indexer_dataloader_spot_price}"
  version          = "${var.version}"
}

resource "aws_security_group" "rds_sg" {

  name = "${var.environment}-rds-sg"

#  vpc_id = "${var.vpc_id}"
  description = "RDS Security Group"

  vpc_id = "${module.vpc.aws_vpc_id}"

  tags {
    Name = "${var.environment}-rds-sg"
  }

  # access from subnets
  ingress {
    from_port = "3306"
    to_port   = "3306"
    protocol  = "tcp"
    security_groups = ["${module.web.asg_sg_id}","${module.content.asg_sg_id}","${module.ticketandpass.asg_sg_id}","${module.stations.asg_sg_id}","${module.nationalrail.asg_sg_id}","${module.tfgmmetrolink.asg_sg_id}","${module.networkimpacts.asg_sg_id}","${module.bus.asg_sg_id}","${module.dataloader.asg_sg_id}"]
  }

  ingress {
    from_port = "3306"
    to_port   = "3306"
    protocol  = "tcp"
    cidr_blocks = ["${split(",", var.ssh_whitelist)}"]
  }


  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

module "rds" {
  source = "../../rds"
  az1_id = "${module.vpc.az1_rds_id}"
  az2_id = "${module.vpc.az2_rds_id}"
  az3_id = "${module.vpc.az3_rds_id}"
  rds_username = "${var.rds_username}"
  rds_password = "${var.rds_password}"
  rds_sg_id = "${aws_security_group.rds_sg.id}"
  environment = "${var.environment}"
  rds_allocated_storage = "${var.rds_allocated_storage}"
  rds_engine = "${var.rds_engine}"
  rds_engine_version = "${var.rds_engine_version}"
  rds_instance_class = "${var.rds_instance_class}"
  rds_parameter_group_name = "${var.rds_parameter_group_name}"
  route53_zone_id = "${var.route53_zone_id}"
  multi_az = "${var.multi_az}"
}

resource "aws_security_group" "elasticache_sg" {

  name = "${var.environment}-elasticache-sg"
  vpc_id = "${module.vpc.aws_vpc_id}"
  description = "Elasticache SG"

  tags {
    Name = "${var.environment}-elasticache-sg"
  }

    # SSH
  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = ["${module.web.asg_sg_id}","${module.content.asg_sg_id}","${module.ticketandpass.asg_sg_id}","${module.stations.asg_sg_id}","${module.nationalrail.asg_sg_id}","${module.tfgmmetrolink.asg_sg_id}","${module.networkimpacts.asg_sg_id}","${module.bus.asg_sg_id}"]
 }


  # outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
module "elasticache"  {
  source = "../../elasticache"
  environment = "${var.environment}"
  service = "elasticache"
  az1_id = "${module.vpc.az1_elasticache_id}"
  az2_id = "${module.vpc.az2_elasticache_id}"
  az3_id = "${module.vpc.az3_elasticache_id}"
  aws_sg_elasticache_id = "${module.vpc.aws_sg_elasticache_id}"
  aws_elasticache_subnet_group_name = "${module.vpc.aws_elasticache_subnet_group_name}"
  aws_elasticache_cluster_parameter_group_name = "${var.aws_elasticache_cluster_parameter_group_name}"
  aws_elasticache_cluster_port = "${var.aws_elasticache_cluster_port}"
  aws_elasticache_cluster_num_cache_nodes = "${var.aws_elasticache_cluster_num_cache_nodes}"
  aws_elasticache_cluster_engine = "${var.aws_elasticache_cluster_engine}"
  aws_elasticache_cluster_node_type = "${var.aws_elasticache_cluster_node_type}"
  route53_zone_id = "${var.route53_zone_id}"
  aws_elasticache_az_mode = "${var.aws_elasticache_az_mode}"
}

resource "aws_route53_record" "external" {
   zone_id = "${var.route53_zone_id}"
   name = "${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "web" {
   zone_id = "${var.route53_zone_id}"
   name = "web.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "content" {
   zone_id = "${var.route53_zone_id}"
   name = "content.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "ticketandpass" {
   zone_id = "${var.route53_zone_id}"
   name = "ticketandpass.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "stations" {
   zone_id = "${var.route53_zone_id}"
   name = "stations.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "nationalrail" {
   zone_id = "${var.route53_zone_id}"
   name = "nationalrail.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "tfgmmetrolink" {
   zone_id = "${var.route53_zone_id}"
   name = "tfgmmetrolink.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "networkimpacts" {
   zone_id = "${var.route53_zone_id}"
   name = "networkimpacts.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "bus" {
   zone_id = "${var.route53_zone_id}"
   name = "bus.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "indexer" {
   zone_id = "${var.route53_zone_id}"
   name = "indexer.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "scheduler" {
   zone_id = "${var.route53_zone_id}"
   name = "scheduler.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "events" {
   zone_id = "${var.route53_zone_id}"
   name = "events.${var.environment}."${var.domain}"
   type = "A"
   alias {
        name =    "${module.frontend.elb_dns}"
        zone_id = "${module.frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}


