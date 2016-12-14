#!/bin/bash 
set -e
set -u

read -r -p "This script fixes all the CodeDeploy hooks if the asgs are destroyed? [y/N] " response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	export AWS_DEFAULT_REGION=eu-west-1
	export AWS_PROFILE=tfgm
	export environment="qa"

	function taint {
		terraform taint -module=$2_vpc.$1 aws_autoscaling_group.asg
		terraform taint -module=$2_vpc.$1 aws_launch_configuration.lc
		terraform taint -module=$2_vpc.$1 aws_autoscaling_schedule.scale_down
		terraform taint -module=$2_vpc.$1 aws_autoscaling_schedule.scale_up
		terraform taint -module=$2_vpc.$1 aws_cloudwatch_metric_alarm.asg_add_capacity_alarm
		terraform taint -module=$2_vpc.$1 aws_cloudwatch_metric_alarm.asg_remove_capacity_alarm
		terraform taint -module=$2_vpc.$1 aws_autoscaling_policy.asg_scaleout_policy
		terraform taint -module=$2_vpc.$1 aws_autoscaling_policy.asg_scalein_policy
	}

	function fix_hooks {
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2 --auto-scaling-groups $2-$1-asg
	    aws autoscaling describe-lifecycle-hooks --auto-scaling-group-name $2-$1-asg
	}

	function fix_hooks_fake {
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2
	    aws deploy  update-deployment-group --application-name $1   --current-deployment-group-name $2 --auto-scaling-groups $3
	    aws autoscaling describe-lifecycle-hooks --auto-scaling-group-name $3
	}

	fix_hooks content ${environment} 
	fix_hooks ticketandpass ${environment} 
	fix_hooks stations ${environment} 
	fix_hooks nationalrail ${environment} 
	fix_hooks tfgmmetrolink ${environment} 
	fix_hooks networkimpacts ${environment} 
	fix_hooks bus ${environment} 
	fix_hooks web ${environment} 
	fix_hooks frontend ${environment}
	fix_hooks scheduler ${environment}
	fix_hooks indexer ${environment}
	fix_hooks events ${environment}
	fix_hooks_fake busdataloader ${environment} ${environment}-dataloader-asg
fi
