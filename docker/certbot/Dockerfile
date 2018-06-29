FROM nginx:alpine

RUN set -ex \
 && rm -rf /etc/letsencrypt \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt \
 && apk add --update --upgrade --no-cache certbot nginx-mod-http-lua

COPY nginx/* /etc/nginx/
COPY bin/*   /usr/local/bin/

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

