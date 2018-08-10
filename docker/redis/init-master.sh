#!/bin/sh
cluster="be-ecs-cluster"
instances=$(aws --output text ecs list-container-instances --cluster $cluster | awk '{print $2}' | tr '\n' ' ')
instance_ids=$(aws --output text ecs describe-container-instances --container-instances $instances --cluster $cluster --query 'containerInstances[*].[ec2InstanceId]')
echo $instance_ids
