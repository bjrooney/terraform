
variable "vpc_id" {
}

variable "cidr" {
}

variable "service_port" {
  default = 8080
}

variable "name" {
}


resource "aws_security_group" "sg" {

  name = "${var.name}"
#  vpc_id = "${var.vpc_id}"
  description = "Security Group"

  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.name}"
  }

  # access from subnets
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.cidr)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "sg_id" {
  value = "${aws_security_group.sg.id}"
}