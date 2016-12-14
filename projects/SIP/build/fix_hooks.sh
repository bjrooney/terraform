
#!/bin/bash 
set -e
set -u

read -r -p "This script fixes all the build hooks if the asgs are destroyed? [y/N] " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	export AWS_DEFAULT_REGION=eu-west-1
	export AWS_PROFILE=tfgm
	export environment="build"


	function fix_hooks {
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2 --auto-scaling-groups $3
	    aws autoscaling describe-lifecycle-hooks --auto-scaling-group-name $3
	}

	function fix_hooks_fake {
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2 --auto-scaling-groups $3
	    aws autoscaling describe-lifecycle-hooks --auto-scaling-group-name $3
	}


	fix_hooks frontend build build-nginx-asg
	fix_hooks web test build-test-asg 

fi

