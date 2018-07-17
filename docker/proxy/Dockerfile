FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --upgrade --no-cache nginx \
 && rm -rf /etc/nginx/conf.d /etc/letsencrypt   \
 && ln -nsf /mnt/nginx /etc/nginx/conf.d        \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt

COPY nginx.conf    /etc/nginx/
COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
EXPOSE 443
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

