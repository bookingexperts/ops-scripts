#!/bin/sh
function main {
  master=$(get_master)
  if [ "$master" != "" ] ; then
    echo "Master found: ${master}. Starting..."
    echo "sentinel monitor queue-master ${master} 2" >> /etc/redis/sentinel.conf
    reset_sentinels &
    redis-sentinel /etc/redis/sentinel.conf
  else
    echo "Master not found! Exiting..."
    sleep 300
    exit 1
  fi
}

# Find master by locating a slave
function get_master {
  for host in $(get_redis_instances); do
    redis_info=$(redis-cli -h $host info | dos2unix | egrep '(role|master_)')
    if echo "$redis_info" | grep -q ^role:slave; then
      host=$(echo "$redis_info" | grep ^master_host | egrep -o '(ip-)?(\d{1,3}[.-]){3}\d{1,3}')
      port=$(echo "$redis_info" | grep ^master_port | egrep -o '\d+')
      echo "${host} ${port}"
      return
    fi
  done
}

# Get other sentinels from target group
function get_sentinels {
  aws elbv2 describe-target-health --output text  --region eu-central-1 \
    --target-group-arn $TARGET_GROUP_ARN | grep -v $(hostname -i) | egrep -o '(\d{1,3}\.){3}\d{1,3}'
}

# Get redis EC2 instances from ASG
function get_redis_instances {
  aws ec2 describe-instances --output text --region eu-central-1 \
    --filters "Name=tag:aws:autoscaling:groupName,Values=$ASG_NAME" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[PrivateDnsName]'
}

# Resets all _other_ sentinels to clean up any old sentinels
function reset_sentinels {
  sleep 60
  echo "Resetting other sentinels in cluster..."
  for host in $(get_sentinels); do
    redis-cli -h $host -p 26379 sentinel reset *
    sleep 30
  done
  echo "All sentinels have been reset..."
}

main
