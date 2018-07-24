#!/bin/sh

updated=/etc/nginx/conf.d/updated
pid=/var/run/nginx.pid

# Exit cleanly on a SIGTERM
trap "{ nginx -s quit }" SIGTERM

$(
  # Auto reload when the config has been updated
  while [ ! -f $pid ] || ([ -f $pid ] && kill -0 $(cat $pid)) 2> /dev/null; do
    # if updated file was more recently touched then nginx.pid
    if [ -f $updated -a $updated -nt $pid ]; then
      # validate & reload config & touch nginx.pid
      nginx -t && nginx -s reload && touch $pid || echo "ERROR: Failed to reload config"
    fi
    sleep 5
  done
) &

# Start nginx
nginx
