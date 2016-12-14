variable "environment" {
}

variable "az1_id" {
}

variable "az2_id" {
}

variable "az3_id" {
}

variable "rds_username" {
}

variable "rds_password" {
}

variable "rds_sg_id" {
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

variable "route53_zone_id" {
}
variable "multi_az" {
  
}

resource "aws_db_subnet_group" "default" {
    name = "${var.environment}-db-subnet-group"
    description = "Our main group of subnets"
    subnet_ids = ["${var.az1_id}","${var.az2_id}","${var.az3_id}"]
    tags {
        Name = "${var.environment}-db-subnet-group"
    }
}

resource "aws_db_instance" "default" {
  allocated_storage    = "${var.rds_allocated_storage}"
  engine               = "${var.rds_engine}"
  engine_version       = "${var.rds_engine_version}"
  instance_class       = "${var.rds_instance_class}"
  name                 = "${var.environment}"
  identifier           = "${var.environment}"
  username             =  "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  parameter_group_name = "${var.rds_parameter_group_name}"
  vpc_security_group_ids = ["${var.rds_sg_id}"]
  multi_az               = "${var.multi_az}"

  backup_window              = "01:54-02:54"
  backup_retention_period    = 7
  maintenance_window         = "Tue:03:05-Tue:04:05"
  auto_minor_version_upgrade = true
  
  publicly_accessible        = true
}

resource "aws_route53_record" "internal" {
   zone_id = "${var.route53_zone_id}"
   name = "rds.${var.environment}.internal."${var.domain}"
   type = "CNAME"
   ttl  = "60"
   records = ["${aws_db_instance.default.address}"]
}

resource "aws_route53_record" "external" {
   zone_id = "${var.route53_zone_id}"
   name = "rds.${var.environment}."${var.domain}"
   type = "CNAME"
   ttl  = "60"
   records = ["${aws_db_instance.default.address}"]
}
