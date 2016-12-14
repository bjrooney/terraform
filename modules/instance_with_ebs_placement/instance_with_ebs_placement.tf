
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

variable "placement_group" {
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "500"
}

variable "delete_on_termination" {

}

resource "aws_instance" "instance" {

  connection {
    # The default username for our AMI
    user = "centos"

    # The connection will use the local SSH agent for authentication.
  }
  
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  iam_instance_profile = "${var.iam_instance_profile}" 
  vpc_security_group_ids = ["${split(",", var.security_group)}"]
  key_name = "${var.keyname}"
    #   placement_group = "${var.placement_group}"
  user_data = "${var.user_data}"


  associate_public_ip_address = false
  root_block_device {
    delete_on_termination = true
  }
   
  ebs_block_device {
    delete_on_termination = "${var.delete_on_termination}"
    device_name = "/dev/sdg"
    volume_type = "${var.volume_type}"
    volume_size = "${var.volume_size}"
  }

  tags {
    Name = "${var.environment}-${var.service}"
  }

}

output "instance_id" {
  value = "${aws_instance.instance.id}"
}

output "public_ip" {
  value = "${aws_instance.instance.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.instance.private_ip}"
}