variable "profile" {
  description = "Profile found in aws ~/.aws/credentials file"
  default = "tfgm"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default = "eu-west-1"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.profile}"
}

resource "terraform_remote_state" "remote_state" {
    backend = "s3"
    config {
        bucket = "terraform-tfgm"
        key = "eips/terraform.tfstate"
        region = "${var.aws_region}"
        profile = "${var.profile}"
    }
}

module "eip_build" {
  source = "../../../modules/eip"
}

output "build_az1_nat_eip_id" {
  value = "${module.eip_build.az1_nat_eip_id}"
}

output "build_az2_nat_eip_id" {
  value = "${module.eip_build.az2_nat_eip_id}"
}

output "build_az3_nat_eip_id" {
  value = "${module.eip_build.az3_nat_eip_id}"
}

module "eip_staging" {
  source = "../../../modules/eip"
}

output "staging_az1_nat_eip_id" {
  value = "${module.eip_staging.az1_nat_eip_id}"
}

output "staging_az2_nat_eip_id" {
  value = "${module.eip_staging.az2_nat_eip_id}"
}

output "staging_az3_nat_eip_id" {
  value = "${module.eip_staging.az3_nat_eip_id}"
}

module "eip_integration" {
  source = "../../../modules/eip"
}

output "integration_az1_nat_eip_id" {
  value = "${module.eip_integration.az1_nat_eip_id}"
}

output "integration_az2_nat_eip_id" {
  value = "${module.eip_integration.az2_nat_eip_id}"
}

output "integration_az3_nat_eip_id" {
  value = "${module.eip_integration.az3_nat_eip_id}"
}

module "eip_production" {
  source = "../../../modules/eip"
}

output "production_az1_nat_eip_id" {
  value = "${module.eip_production.az1_nat_eip_id}"
}

output "production_az2_nat_eip_id" {
  value = "${module.eip_production.az2_nat_eip_id}"
}

output "production_az3_nat_eip_id" {
  value = "${module.eip_production.az3_nat_eip_id}"
}


