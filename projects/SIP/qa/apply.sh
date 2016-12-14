#!/bin/bash 
set -e
set -u

read -r -p "Are you sure you want to run apply ? [y/N] " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]];
then
	export AWS_PROFILE=tfgm
	export AWS_DEFAULT_REGION=eu-west-1
	terraform remote config -backend=s3 -backend-config="bucket=terraform-tfgm" -backend-config="key=sip-qa/terraform.tfstate" -backend-config="region=eu-west-1"

    timestamp="S"$(date +"%Y%m%d%H%M%S")
    echo $timestamp
	terraform get
#	terraform refresh -var-file ../variables/variables.tfvars -var-file ../variables/creds.tfvars  -var "version=$timestamp"
	terraform apply   -var-file ../variables/variables.tfvars -var-file ../variables/creds.tfvars  -var "version=$timestamp"
fi
