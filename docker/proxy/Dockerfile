FROM nginx:alpine

COPY nginx.conf    /etc/nginx/
COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
EXPOSE 80 443
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh

# Setup config mountpoints
RUN set -ex \
 && rm -rf /etc/nginx/conf.d /etc/letsencrypt \
 && ln -nsf /mnt/nginx /etc/nginx/conf.d \
 && ln -nsf /mnt/letsencrypt /etc/letsencrypt
