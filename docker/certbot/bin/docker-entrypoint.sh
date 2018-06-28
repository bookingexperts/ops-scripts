#!/bin/sh

# Exit cleanly on a SIGTERM
trap "{ nginx -s quit }" SIGTERM

# Start nginx (in BG)
nginx

# Start crond
crond -f
