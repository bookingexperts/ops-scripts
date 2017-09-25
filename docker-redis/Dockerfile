FROM redis:3-alpine

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY lru.conf queue.conf sentinel.conf /etc/redis/

CMD ["queue"]
