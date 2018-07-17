FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
 && apk add --update --upgrade --no-cache nginx-mod-http-lua nginx curl                    \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.7/main certbot \
 && rm -rf /etc/letsencrypt                                                                \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt

COPY nginx/* /etc/nginx/
COPY bin/*   /usr/local/bin/
ADD  crontab /etc/periodic/daily/renew

RUN chmod 0644 /etc/periodic/daily/renew

EXPOSE 80
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
