resource "aws_eip" "az1_nat_eip" {
  vpc = true
}

resource "aws_eip" "az2_nat_eip" {
  vpc = true
}

resource "aws_eip" "az3_nat_eip" {
  vpc = true
}

output "az1_nat_eip_id" {
  value = "${aws_eip.az1_nat_eip.id}"
}

output "az2_nat_eip_id" {
  value = "${aws_eip.az2_nat_eip.id}"
}

output "az3_nat_eip_id" {
  value = "${aws_eip.az3_nat_eip.id}"
}

output "az1_nat_eip" {
  value = "${aws_eip.az1_nat_eip.public_ip}"
}

output "az2_nat_eip" {
  value = "${aws_eip.az2_nat_eip.public_ip}"
}

output "az3_nat_eip" {
  value = "${aws_eip.az3_nat_eip.public_ip}"
}