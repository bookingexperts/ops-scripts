FROM alpine:3.7

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.8/main \
    nginx-mod-http-lua nginx \
 && apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    certbot  \
 && apk add --no-cache --update openssl curl \
 && mkdir -p /usr/share/nginx/html       \
 && rm -rf /etc/letsencrypt              \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt

COPY nginx   /etc/nginx/
COPY bin     /usr/local/bin/

EXPOSE 80
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
