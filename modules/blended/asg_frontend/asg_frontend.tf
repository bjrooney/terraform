variable "environment" {
}

variable "service" {
}

variable "instance_type" {
  description = "AWS instance type"
}

variable "vpc_id" {
}

variable "az1_id" {
}

variable "az2_id" {
}

variable "az3_id" {
}

variable "internal" {
}

variable "iam_instance_profile" {
}

variable "service_port" {
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

variable "image_id" {
}

variable "whitelist" {
}

variable "elb_whitelist" {
}

variable "key_name" {
  default = "green"
  description = "Name of AWS key pair"
}

variable "user_data" {

}

variable "timeout" {
  default =10
}

variable "route53_zone_id" {
  default = "Z17193RXKERR57"
}

variable "elb_interval" {

}

variable "scale_down_size" {

}

variable "scale_up_recurrence" {

}

variable "scale_down_recurrence" {

}


variable "version" {

}

variable "pingdom1" {
}

variable "pingdom2" {
}

variable "pingdom3" {
}

variable "ssl_certificate" {
}

# Backend ASG
resource "aws_security_group" "peering_sg" {
  name = "${var.environment}-${var.service}-peering-sg"
  vpc_id = "${var.vpc_id}"
  description = "SSH peering"

  tags {
    Name = "${var.environment}-${var.service}-peering-sg"
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

# Backend ASG
resource "aws_security_group" "asg_sg" {
  name = "${var.environment}-${var.service}-asg-sg"
  vpc_id = "${var.vpc_id}"
  description = "ASG Service Port"

  tags {
    Name = "${var.environment}-${var.service}-asg-sg"
  }

  # access from subnets
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# ELB ASG
resource "aws_security_group" "elb_sg" {
  name = "${var.environment}-${var.service}-elb-sg"
  vpc_id = "${var.vpc_id}"
  description = "ELB SG"

  tags {
    Name = "${var.environment}-${var.service}-elb-sg"
  }


  # access VPC
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.elb_whitelist)}"]
  }
  # access VPC
  ingress {
    from_port = 443
    to_port   = 443
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.elb_whitelist)}"]
  }
  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "sg_elb_id" {
  value = "${aws_security_group.elb_sg.id}"
}

output "asg_sg_id" {
  value = "${aws_security_group.asg_sg.id}"
}

# ELB ASG
resource "aws_security_group" "elb_sg_ping_1" {
  name = "${var.environment}-${var.service}-elb-sg-pingdom1"
  vpc_id = "${var.vpc_id}"
  description = "${var.environment}-${var.service}-elb-sg-pingdom1"

  tags {
    Name = "${var.environment}-${var.service}-elb-sg-pingdom1"
  }


  # access VPC
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.pingdom1)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# ELB ASG
resource "aws_security_group" "elb_sg_ping_2" {
  name = "${var.environment}-${var.service}-elb-sg-pingdom2"
  vpc_id = "${var.vpc_id}"
  description = "${var.environment}-${var.service}-elb-sg-pingdom2"

  tags {
    Name = "${var.environment}-${var.service}-elb-sg-pingdom2"
  }


  # access VPC
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.pingdom2)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# ELB ASG
resource "aws_security_group" "elb_sg_ping_3" {
  name = "${var.environment}-${var.service}-elb-sg-pingdom3"
  vpc_id = "${var.vpc_id}"
  description = "${var.environment}-${var.service}-elb-sg-pingdom3"

  tags {
    Name = "${var.environment}-${var.service}-elb-sg-pingdom3"
  }


  # access VPC
  ingress {
    from_port = "${var.service_port}"
    to_port = "${var.service_port}"
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.pingdom3)}"]
  }

  # Outbound 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# ELB HTTP on port 80 and 443
resource "aws_elb" "elb" {
  name = "${var.environment}-${var.service}-elb"
  subnets         = ["${var.az1_id}","${var.az2_id}","${var.az3_id}"]

  # Security group
  security_groups = ["${aws_security_group.elb_sg_ping_1.id}","${aws_security_group.elb_sg_ping_2.id}","${aws_security_group.elb_sg_ping_3.id}","${aws_security_group.elb_sg.id}"]

  internal = "${var.internal}"

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  listener {
    instance_port = "${var.service_port}"
    instance_protocol = "http"
    lb_port = "${var.service_port}"
    lb_protocol = "http"
  }

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.ssl_certificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "HTTP:80/elb-status"
    interval = "${var.elb_interval}"
  }

}

output "elb_dns" {
  value = "${aws_elb.elb.dns_name}"
}

output "elb_zone_id" {
  value = "${aws_elb.elb.zone_id}"
}


# Launch Configuartion
resource "aws_launch_configuration" "lc" {
  name = "${var.environment}-${var.service}-${var.version}-lc"
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  # Security group
  user_data = "${var.user_data}"
  security_groups = ["${aws_security_group.asg_sg.id}","${aws_security_group.peering_sg.id}"]

  key_name = "${var.key_name}"

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
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  desired_capacity = "${var.asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.lc.name}"
  load_balancers = ["${var.environment}-${var.service}-elb"]
  health_check_type = "ELB"
  health_check_grace_period = 600
  termination_policies = ["OldestInstance"]
  tag {
    key = "Name"
    value = "${var.environment}-${var.service}"
    propagate_at_launch = "true"
  }
}

resource "aws_autoscaling_notification" "asg_notification" {
  group_names = [
    "${aws_autoscaling_group.asg.name}"
  ]
  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH", 
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
  topic_arn = "arn:aws:sns:eu-west-1:050124427385:${var.environment}-asg"
}

resource "aws_cloudwatch_metric_alarm" "asg_add_capacity_alarm" {
    depends_on = ["aws_autoscaling_group.asg"]
    alarm_name = "${var.environment}-${var.service}-asg-add-capacity-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "80"
    alarm_description = "Add Capacity"
    alarm_actions = ["${aws_autoscaling_policy.asg_scaleout_policy.arn}"]
    insufficient_data_actions = []
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "asg_remove_capacity_alarm" {
    depends_on = ["aws_autoscaling_group.asg"]
    alarm_name = "${var.environment}-${var.service}-asg-remove-capacity-alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "40"
    alarm_description = "Remove Capacity"
    alarm_actions = ["${aws_autoscaling_policy.asg_scalein_policy.arn}"]
    insufficient_data_actions = []
    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
    }
}

resource "aws_autoscaling_policy" "asg_scaleout_policy" {
  depends_on = ["aws_autoscaling_group.asg"]
  name = "${var.environment}-${var.service}-asg-scaleout-policy"
  scaling_adjustment = 3
  adjustment_type = "PercentChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "asg_scalein_policy" {
  depends_on = ["aws_autoscaling_group.asg"]
  name = "${var.environment}-${var.service}-asg-scalein-policy"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_route53_record" "internal" {
   zone_id = "${var.route53_zone_id}"
   name = "${var.service}.${var.environment}.internal."${var.domain}"
   type = "A"
   alias {
        name =    "${aws_elb.elb.dns_name}"
        zone_id = "${aws_elb.elb.zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_autoscaling_schedule" "scale_up" {
    depends_on = ["aws_autoscaling_group.asg"]
    scheduled_action_name = "${var.environment}-${var.service}-scale-up"
    min_size = "${var.asg_min}"
    max_size = "${var.asg_max}"
    desired_capacity = "${var.asg_desired}"
    recurrence             = "${var.scale_up_recurrence}"
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_schedule" "scale_down" {
    depends_on = ["aws_autoscaling_group.asg"]
    scheduled_action_name  = "${var.environment}-${var.service}-scale-down"
    min_size               = "${var.scale_down_size}"
    max_size               = "${var.asg_max}"
    desired_capacity       = "${var.scale_down_size}"
    recurrence             = "${var.scale_down_recurrence}"
    autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
