#!/bin/sh

# Exit cleanly on a SIGTERM
trap "{ nginx -s quit }" SIGTERM

# Start crond
crond

# It seems starting crond removes these symlinks when build in the dockerfile
ln -nsf /usr/local/bin/maintenance /etc/periodic/daily/maintenance
ln -nsf /usr/local/bin/rotate_session_keys /etc/periodic/hourly/rotate_session_keys

# Start nginx
nginx
