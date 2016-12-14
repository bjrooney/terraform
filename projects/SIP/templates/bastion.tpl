#!/bin/bash -v
set -e
set -u

INSTANCE_ID=$(ec2metadata --instance-id)

aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${BASTION_EIP_ID} --region=eu-west-1


