FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV='production' \
    RUBY_GC_HEAP_INIT_SLOTS=500000  \
    RUBY_GC_HEAP_FREE_SLOTS=500000  \
    RUBY_GC_HEAP_GROWTH_FACTOR=1.25 \
    RUBY_GC_MALLOC_LIMIT=64000000   \
    RUBY_GC_OLDMALLOC_LIMIT=64000000
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
