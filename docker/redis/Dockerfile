FROM redis:alpine3.8

RUN set -ex \
 && apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing aws-cli
COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY sentinel.conf /etc/redis/
