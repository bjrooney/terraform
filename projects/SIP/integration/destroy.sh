#!/bin/bash 
set -e
set -u

read -r -p "Are you sure you wish to destroy the entire INTEGRATION environment? [y/N] " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then

	export AWS_PROFILE=tfgm
	export AWS_DEFAULT_REGION=eu-west-1
    terraform remote config -backend=s3 -backend-config="bucket=terraform-tfgm" -backend-config="key=sip-integration/terraform.tfstate" -backend-config="region=eu-west-1"

	terraform get
	terraform destroy -var-file ../variables/variables.tfvars  -var-file ../variables/creds.tfvars  -var "version=destroy" 
fi
