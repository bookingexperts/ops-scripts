#!/bin/sh
function set_master {
  master="$(redis-cli -h sentinel.ecs.be.internal -p 26379 sentinel get-master-addr-by-name queue-master || echo 'Connection refused')"
  master=$(echo "$master" | tr '\n' ' ')
}

mode=$1
shift
case $mode in
sentinel)
  while true; do
    set_master
    case "$master" in
    *"Connection refused"*)
      echo "No active sentinels found, starting..."
      break
      ;;
    "")
      echo "Waiting for master to be registered..."
      sleep 5
      ;;
    *"6379"*)
      echo "sentinel monitor queue-master ${master} 2" >> /etc/redis/sentinel.conf
      break
      ;;
    *)
      echo "Something went wrong... This is the master:"
      echo $master
      break
      ;;
    esac
  done
  redis-sentinel /etc/redis/sentinel.conf ${@}
  ;;
queue)
  set_master
  case "$master" in
  *"Connection refused"*|"")
    echo "No master found, starting as master..."
    ;;
  *"6379"*)
    echo "slaveof ${master}" >> /etc/redis/queue.conf
    ;;
  esac
  redis-server /etc/redis/queue.conf ${@}
  ;;
*)
  echo "Invalid mode. Usage $0 (sentinel|queue)"
  ;;
esac
