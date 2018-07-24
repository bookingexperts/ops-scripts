FROM alpine:3.7

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.8/main \
    nginx-mod-http-lua nginx \
 && apk add --no-cache --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    certbot  \
 && apk add --no-cache --update openssl curl \
 && mkdir -p /usr/share/nginx/html       \
 && rm -rf /etc/letsencrypt              \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt

COPY nginx   /etc/nginx/
COPY bin     /usr/local/bin/

RUN set -ex \
  ln -nsf /usr/local/bin/renew /etc/periodic/daily/renew \
  ln -nsf /usr/local/bin/rotate_session_keys /etc/periodic/hourly/rotate_session_keys

EXPOSE 80
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
