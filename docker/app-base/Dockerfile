FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV='production' \
    RUBY_GC_HEAP_INIT_SLOTS=500000 \
    RUBY_GC_HEAP_FREE_SLOTS=6600000 \
    RUBY_GC_HEAP_GROWTH_FACTOR=1.03 \
    RUBY_GC_HEAP_GROWTH_MAX_SLOTS=1100000 \
    RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.0 \
    RUBY_GC_MALLOC_LIMIT=40000000 \
    RUBY_GC_MALLOC_LIMIT_MAX=70000000 \
    RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.32 \
    RUBY_GC_OLDMALLOC_LIMIT=30000000 \
    RUBY_GC_OLDMALLOC_LIMIT_MAX=59000000 \
    RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2
ENTRYPOINT ["bundle", "exec"]
CMD ["web-start"]

RUN set -ex \
 # Install dependecies
 && apk add --update --upgrade --no-cache --virtual .run-deps \
    dumb-init \
    file \
    imagemagick \
    less \
    libpq \
    libstdc++ \
    libsodium \
    nginx \
    postgresql-client \
    ruby-bundler \
    ruby-full \
    tzdata \
    yaml

ARG revision

COPY nginx.conf /etc/nginx/

RUN mkdir -p tmp config \
 && cd config \
 && ln -s database.deploy.yml database.yml \
 && cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
