#!/bin/sh
set -ex

function main {
  if [ "$(get_sentinels)" == "" ]; then
    redis-sentinel /etc/redis/sentinel.conf
  else
    join_cluster && redis-sentinel /etc/redis/sentinel.conf
  fi
}

function get_master {
  master="$(redis-cli -h sentinel.be.internal -p 26379 sentinel get-master-addr-by-name queue-master || echo 'Connection refused')"
  echo "$master" | tr '\n' ' '
}

# Get other sentinel ip adresses fron target group
function get_sentinels {
  aws elbv2 describe-target-health --output text --target-group-arn $TARGET_GROUP_ARN | grep -v $(hostname -i) | egrep -o '(\d{1,3}\.){3}\d{1,3}'
}

# Resets all _other_ sentinels
function reset_sentinels {
  for host in $(get_sentinels); do
    redis-cli -h $host -p 26379 sentinel reset *
    sleep 30
  done
}

function join_cluster {
  while true; do
    master=$(get_master)
    case "$master" in
    *"6379"*)
      echo "Master found: ${master}. Join cluster..."
      echo "sentinel monitor queue-master ${master} 2" >> /etc/redis/sentinel.conf
      reset_sentinels
      break
      ;;
    *)
      sleep 5
      ;;
    esac
  done
}

main
