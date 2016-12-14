variable "environment" {
}

variable "service" {
}

variable "az1_id" {
}

variable "az2_id" {
}

variable "az3_id" {
}

variable "aws_sg_elasticache_id" {
}

variable "aws_elasticache_subnet_group_name" {
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
variable "route53_zone_id" {
}

variable "aws_elasticache_az_mode" {
}

resource "aws_elasticache_cluster" "default" {
    cluster_id = "${var.environment}"
    engine =     "${var.aws_elasticache_cluster_engine}"
    node_type =  "${var.aws_elasticache_cluster_node_type}"
    port =       "${var.aws_elasticache_cluster_port}"
    num_cache_nodes =      "${var.aws_elasticache_cluster_num_cache_nodes}"
    parameter_group_name  = "${var.aws_elasticache_cluster_parameter_group_name}"
    security_group_ids    =   ["${var.aws_sg_elasticache_id}"]
    subnet_group_name     =   "${var.aws_elasticache_subnet_group_name}" 
    maintenance_window    = "Tue:03:05-Tue:04:05"
    snapshot_window       = "01:54-02:54"
}
 
resource "aws_route53_record" "elasticache" {
   depends_on = ["aws_elasticache_cluster.default"]
   zone_id = "${var.route53_zone_id}"
   name = "redis.${var.environment}."${var.domain}"
   type = "CNAME"
   ttl = "60"
   records = ["${aws_elasticache_cluster.default.cache_nodes.0.address}"]
}