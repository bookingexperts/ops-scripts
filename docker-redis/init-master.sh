#!/bin/sh
instances=$(aws --output text ecs list-container-instances --cluster ecs-test | awk '{print $2}' | tr '\n' ' ')
instance_ids=$(aws --output text ecs describe-container-instances --container-instances  --cluster ecs-test --query 'containerInstances[*].[ec2InstanceId]')
