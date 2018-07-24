#!/bin/sh

# Exit cleanly on a SIGTERM
trap "{ nginx -s quit }" SIGTERM

# Start crond
crond

# Start nginx
nginx
