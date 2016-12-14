
variable "environment" {
}

variable "service" {
}

variable "instance_type" {
  description = "AWS instance type"
}

variable "region" {
}

variable "ami" {
}

variable "vpc_id" {
}

variable "az1_id" {
}

variable "az2_id" {
}

variable "az3_id" {
}

variable "iam_instance_profile" {
}

variable "security_group" {
}

variable "keyname" {
}

variable "subnet_id" {
}

variable "user_data" {

}


# Launch Configuartion
resource "aws_launch_configuration" "lc" {
  name_prefix = "${var.environment}-${var.service}-lc-"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  # Security group
  user_data = "${var.user_data}"
  security_groups = ["${split(",", var.security_group)}"]

  key_name = "${var.keyname}"

  iam_instance_profile = "${var.iam_instance_profile}"

  associate_public_ip_address = false

  ebs_optimized = false
  
  enable_monitoring = true
  root_block_device {
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaling group
resource "aws_autoscaling_group" "asg" {
  depends_on = ["aws_launch_configuration.lc"]
  vpc_zone_identifier = ["${var.az1_id}","${var.az2_id}","${var.az3_id}"]
  name = "${var.environment}-${var.service}-asg"
  max_size = 1
  min_size = 1
  desired_capacity = 1
  force_delete = true
  launch_configuration = "${aws_launch_configuration.lc.name}"
  health_check_type = "EC2"
  health_check_grace_period = 600
  termination_policies = ["OldestInstance"]
  tag {
    key = "Name"
    value = "${var.environment}-${var.service}"
    propagate_at_launch = "true"
  }
}
