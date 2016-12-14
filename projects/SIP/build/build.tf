variable "profile" {
  description = "Profile found in aws ~/.aws/credentials file"
  default = "tfgm"
}

variable "environment" {
  default = "build"
}

variable "ami" {
  default = "ami-25254456"
}

variable "openvpn_ami" {
  default = "ami-0cb32b7f"
}

variable "keyname" {
  default = "green"  
}

variable "instance_type" {
  default = "t2.micro"
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

variable "VALMAN" {
  description = "Valtech Manchester external ip for whitelisting"
  default ="51.179.154.252/32"
}

variable "public_truncated_whitelist" {
  description = "Valtech Manchester external ip for whitelisting"
  default ="51.179.154.252/32"
}

variable "public_whitelist" {
  description = "Public external ip for whitelisting"
  default ="51.179.154.252/32,52.209.26.115/32,52.208.255.116/32,52.208.221.16/32,52.208.228.145/32,52.208.224.5/32,52.209.21.240/32,52.50.216.114/32,52.209.30.142/32,52.209.49.154/32,52.209.3.118/32,52.209.58.7/32,52.31.71.162/32"
}

variable "whitelist" {
  description = "Internal ip for whitelisting"
  default ="172.17.0.0/16,172.18.0.0/16,172.19.0.0/16,172.20.0.0/16,172.21.0.0/16"
}

variable "iam_instance_profile" {
  default = "awsInstanceRole"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default = "eu-west-1"
}

variable "route53_zone_id" {
  default = "Z17193RXKERR57"
}

variable "build_az1_nat_eip_id" {
  default = "eipalloc-b0e2a9d5"
}

variable "build_az2_nat_eip_id" {
  default = "eipalloc-3feda65a"
}

variable "build_az3_nat_eip_id" {
  default = "eipalloc-7eeca71b"
}

variable "build_cidr" {
  default = "172.17.0.0/16"
}

variable "bastion_cidr" {
  default = "172.21.0.0/16"
}

# Template for initial configuration bash script
resource "template_file" "openvpn" {
    template = "${file("../templates/jumpbox.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "nginx" {
    template = "${file("../templates/nginx.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "node" {
    template = "${file("../templates/node.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "java" {
    template = "${file("../templates/java.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "jenkins" {
    template = "${file("../templates/jenkins.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "artifactory" {
    template = "${file("../templates/artifactory.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "sonar" {
    template = "${file("../templates/sonar.tpl")}"
}

# Template for initial configuration bash script
resource "template_file" "fat" {
    template = "${file("../templates/fat.tpl")}"
}

resource "terraform_remote_state" "remote_state" {
    backend = "s3"
    config {
        bucket = "terraform-tfgm"
        key = "build/terraform.tfstate"
        region = "${var.aws_region}"
        profile = "${var.profile}"
    }
}

resource "aws_placement_group" "placement-az1" {
     name = "ci-az1-pg"
     strategy = "cluster"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.profile}"
}

module "build_vpc" {
  source = "../../../modules/vpc"
  environment = "${var.environment}"
  service = "vpc"
  cidr             = "${var.build_cidr}"
  az1_cidr_public  = "172.17.1.0/24"
  az2_cidr_public  = "172.17.2.0/24"
  az3_cidr_public  = "172.17.3.0/24"
  az1_cidr_private = "172.17.200.0/24"
  az2_cidr_private = "172.17.201.0/24"
  az3_cidr_private = "172.17.202.0/24"
  az1_nat_eip_id   = "${var.build_az1_nat_eip_id}"
  az2_nat_eip_id   = "${var.build_az2_nat_eip_id}"
  az3_nat_eip_id   = "${var.build_az3_nat_eip_id}"
  az1_rds          = "172.17.210.0/24"
  az2_rds          = "172.17.211.0/24"
  az3_rds          = "172.17.212.0/24"
  az1_elasticache  = "172.17.220.0/24"
  az2_elasticache  = "172.17.221.0/24"
  az3_elasticache  = "172.17.222.0/24"
  whitelist        = "${var.public_whitelist}"

}

module "build_frontend" {
  source = "../../../modules/asg"
  environment = "${var.environment}"
  service = "nginx"
  image_id = "${var.ami}"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  az1_id = "${module.build_vpc.az1_cidr_public_id}"
  az2_id = "${module.build_vpc.az2_cidr_public_id}"
  az3_id = "${module.build_vpc.az3_cidr_public_id}"
  user_data = "${template_file.nginx.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = false
  service_port = 80
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.whitelist}"
  elb_whitelist = "${var.public_whitelist}"
}


module "test" {
  source = "../../../modules/asg"
  environment = "${var.environment}"
  service = "test"
  image_id = "ami-27630054"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  az1_id = "${module.build_vpc.az1_cidr_private_id}"
  az2_id = "${module.build_vpc.az2_cidr_private_id}"
  az3_id = "${module.build_vpc.az3_cidr_private_id}"
  user_data = "${template_file.node.rendered}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  asg_desired = "${var.asg_desired}"
  internal = true
  service_port = 3001
  instance_type = "t2.small"
  iam_instance_profile = "${var.iam_instance_profile}"
  bastion_cidr = "${var.bastion_cidr}"
  whitelist = "${var.whitelist}"  
  elb_whitelist = "${var.build_cidr}"
}

resource "aws_route53_record" "web_test_public" {
   zone_id = "${var.route53_zone_id}"
   name = "test."${var.domain}"
   type = "A"
   alias {
        name = "${module.build_frontend.elb_dns}"
        zone_id = "${module.build_frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_security_group" "private_sg" {

  name = "build-private-sg"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  description = "ASG Service Port"

  tags {
    Name = "build-private-sg"
  }

  # access from subnets
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${module.build_frontend.asg_sg_id}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "peering_ssh_sg" {
  name = "build-ssh-peering-sg"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  description = "SSH peering"

  tags {
    Name = "build-ssh-peering-sg"
  }

  # access from subnets
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "jenkins_sonar_artifactory" {
  name =   "jenkins-sonar-artifactory-sg"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  tags {
    Name = "jenkins-sonar-artifactory-sg"
  }
  # jenkins
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # artifactory
  ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # sonar
  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

    # webtest
  ingress {
    from_port = 3001
    to_port = 3001
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

    # mock
  ingress {
    from_port = 1080
    to_port = 1080
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${split(",", var.whitelist)}"]
  }

}

resource "aws_security_group" "ssh-build" {

  name = "build-ssh-sg"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  description = "ASG SSH"

  tags {
    Name = "build-ssh-sg"
  }

  # SSH
  ingress {
    from_port = 22
    to_port =   22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.public_truncated_whitelist)}"]
  }

  # HTTPS
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.public_truncated_whitelist)}"]
  }

  # VPN
  ingress {
    from_port = 943
    to_port = 943
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.public_truncated_whitelist)}"]
  }

  # VPN
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["${split(",", var.public_truncated_whitelist)}"]
  }

  # outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "build_jenkins" {
  source = "../../../modules/instance_with_ebs_placement"
  environment = "${var.environment}"
  service = "jenkins"
  region = "${var.aws_region}"
  instance_type = "m3.medium"
  ami = "${var.ami}"
  user_data = "${template_file.jenkins.rendered}"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_group = "${aws_security_group.private_sg.id},${aws_security_group.peering_ssh_sg.id},${aws_security_group.jenkins_sonar_artifactory.id}"
  keyname = "${var.keyname}"
  subnet_id = "${module.build_vpc.az1_cidr_private_id}"
  delete_on_termination = false
  volume_type = "gp2"
  volume_size = "200"
  placement_group = "${aws_placement_group.placement-az1.id}"
}

resource "aws_route53_record" "jenkins_internal" {
   zone_id = "${var.route53_zone_id}"
   name = "jenkins.internal."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${module.build_jenkins.private_ip}"]
}

resource "aws_route53_record" "jenkins_public" {
   zone_id = "${var.route53_zone_id}"
   name = "jenkins."${var.domain}"
   type = "A"
   alias {
         name = "${module.build_frontend.elb_dns}"
        zone_id = "${module.build_frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

module "build_artifactory" {
  source = "../../../modules/instance_with_ebs_placement"
  environment = "${var.environment}"
  service = "artifactory"
  region = "${var.aws_region}"
  instance_type = "m3.medium"
  ami = "${var.ami}"
  user_data = "${template_file.artifactory.rendered}"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_group = "${aws_security_group.private_sg.id},${aws_security_group.peering_ssh_sg.id},${aws_security_group.jenkins_sonar_artifactory.id}"
  keyname = "${var.keyname}"
  subnet_id = "${module.build_vpc.az1_cidr_private_id}"
  delete_on_termination = false
  volume_type = "gp2"
  volume_size = "200"
  placement_group = "${aws_placement_group.placement-az1.id}"
}

resource "aws_route53_record" "artifactory_internal" {
   zone_id = "${var.route53_zone_id}"
   name = "artifactory.internal."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${module.build_artifactory.private_ip}"]
}

resource "aws_route53_record" "artifactory_public" {
   zone_id = "${var.route53_zone_id}"
   name = "artifactory."${var.domain}"
   type = "A"
   alias {
        name = "${module.build_frontend.elb_dns}"
        zone_id = "${module.build_frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

module "build_sonar" {
  source = "../../../modules/instance_with_ebs_placement"
  environment = "${var.environment}"
  service = "sonar"
  region = "${var.aws_region}"
  instance_type = "m3.medium"
  ami = "${var.ami}"
  user_data = "${template_file.sonar.rendered}"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_group = "${aws_security_group.private_sg.id},${aws_security_group.peering_ssh_sg.id},${aws_security_group.jenkins_sonar_artifactory.id}"
  keyname = "${var.keyname}"
  subnet_id = "${module.build_vpc.az1_cidr_private_id}"
  delete_on_termination = true
  volume_type = "gp2"
  volume_size = "10"
  placement_group = "${aws_placement_group.placement-az1.id}"
}

resource "aws_route53_record" "sonar_internal" {
   zone_id = "${var.route53_zone_id}"
   name = "sonar.internal."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${module.build_sonar.private_ip}"]
}

resource "aws_route53_record" "sonar_public" {
   zone_id = "${var.route53_zone_id}"
   name = "sonar."${var.domain}"
   type = "A"
   alias {
         name = "${module.build_frontend.elb_dns}"
        zone_id = "${module.build_frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}

module "build_bastion" {
  source = "../../../modules/instance"
  environment = "${var.environment}"
  service = "bastion"
  region = "${var.aws_region}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  user_data = "${template_file.openvpn.rendered}"
  vpc_id = "${module.build_vpc.aws_vpc_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  security_group = "${aws_security_group.ssh-build.id}"
  keyname = "${var.keyname}"
  subnet_id = "${module.build_vpc.az1_cidr_public_id}"
}

resource "aws_route53_record" "bastion" {
   zone_id = "${var.route53_zone_id}"
   name = "bastion.${var.environment}."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${module.build_bastion.public_ip}"]
}

resource "aws_route53_record" "bastion_internal" {
   zone_id = "${var.route53_zone_id}"
   name = "bastion.${var.environment}.internal."${var.domain}"
   type = "A"
   ttl = "60"
   records = ["${module.build_bastion.private_ip}"]
}


resource "aws_route53_record" "mock_public" {
   zone_id = "${var.route53_zone_id}"
   name = "mock."${var.domain}"
   type = "A"
   alias {
         name = "${module.build_frontend.elb_dns}"
        zone_id = "${module.build_frontend.elb_zone_id}"
        evaluate_target_health = true
    }
}









