#!/bin/bash
function confirm() {
  echo -n "$@ "
  read answer
  for response in y Y yes YES Yes Sure sure SURE OK ok Ok
  do
    if [ "_$answer" == "_$response" ]
    then
      return 0
    fi
  done

  # Any answer other than the list above is considerred a "no" answer
  return 1
}


asg_running_instance_ids() {
  aws ec2 describe-instances --output text \
    --filters "Name=tag:aws:autoscaling:groupName,Values=${1}" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId]'
  }

detach_and_replace() {
  if [ -z "$3" ]; then
    msg="Detach & replace ${1} from ${2}?"
  else
    msg=$3
  fi
  if confirm ${msg}; then
    aws autoscaling detach-instances \
      --instance-ids ${1} \
      --auto-scaling-group-name ${2} \
      --no-should-decrement-desired-capacity > /dev/null
  else
    false
  fi
}

terminate() {
  if confirm "Terminate ${1}?"; then
    aws ec2 terminate-instances \
      --instance-ids ${1} > /dev/null
  fi
}

