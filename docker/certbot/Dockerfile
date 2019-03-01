FROM alpine:3.9

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --upgrade --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev \
 && apk add --update --upgrade --no-cache \
    bind-tools \
    certbot \
    curl \
    nginx \
    nginx-mod-http-lua \
    openssl \
    vim \
 && pip3 install certbot-dns-route53 \
 && mkdir -p /usr/share/nginx/html \
 && rm -rf /etc/letsencrypt \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt \
 && apk del --virtual .build-deps

COPY nginx   /etc/nginx/
COPY bin     /usr/local/bin/

EXPOSE 80
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
