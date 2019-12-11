FROM alpine

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --upgrade --no-cache --virtual .build-deps \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev \
 && apk add --update --upgrade --no-cache \
    bash \
    bind-tools \
    curl \
    jq \
    nginx \
    nginx-mod-http-lua \
    openssl \
    python3 \
    vim \
 && pip3 install certbot certbot-dns-route53 awscli \
 && mkdir -p /usr/share/nginx/html \
 && rm -rf /etc/letsencrypt \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt \
 && apk del .build-deps

COPY nginx   /etc/nginx/
COPY bin     /usr/local/bin/

EXPOSE 80
CMD /usr/local/bin/docker-entrypoint.sh
