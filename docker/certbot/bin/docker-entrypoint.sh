#!/bin/sh

# Exit cleanly on a SIGTERM
trap "{ nginx -s quit }" SIGTERM

# Start crond
crond

# It seems starting crond removes these symlinks when build in the dockerfile
ln -nsf /usr/local/bin/renew /etc/periodic/daily/renew
ln -nsf /usr/local/bin/rotate_session_keys /etc/periodic/hourly/rotate_session_keys
ln -nsf /usr/local/bin/backup /etc/periodic/daily/backup

# Start nginx
nginx
