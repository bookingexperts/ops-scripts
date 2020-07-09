FROM ruby:2.6-alpine3.10

LABEL maintainer "arthur@bookingexperts.nl"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV='production' \
    BUNDLE_GITHUB__HTTPS=true

ENTRYPOINT ["bundle", "exec"]
CMD ["web-start"]

RUN set -ex \
 # Install dependecies
 && apk add --update --upgrade --no-cache --virtual .run-deps \
    ca-certificates \
    curl \
    git \
    imagemagick \
    less \
    libpq \
    libsodium \
    nginx \
    nodejs \
    postgresql-client \
    tar \
    tzdata \
    vim \
    wget \
    yaml \
    yarn \
 # install Build tools
 && apk add --update --upgrade --no-cache --virtual .build-deps \
    build-base \
    postgresql-dev \
    zlib-dev \
 # Update rubygems & bundler
 && gem update --system --no-doc \
 && gem install bundler --no-doc \
 # Build PGRepack
 && update-ca-certificates \
 && wget https://api.pgxn.org/dist/pg_repack/1.4.3/pg_repack-1.4.3.zip \
 && unzip pg_repack-1.4.3.zip \
 && cd pg_repack-1.4.3 \
 # Patch for pg 11 support
 && wget https://github.com/reorg/pg_repack/commit/9bfd94562e77ead67dfcc1713916f862a4a8ee4d.patch -O pg11.patch \
 && patch -p1 -i ./pg11.patch \
 && make install \
 && cd .. \
 # Cleanup
 && apk del .build-deps \
 && rm -rf \
    /root/.gem \
    /root/.bundle \
    ./vendor/bundle/ruby/*/cache \
    ./pg_repack-*

COPY nginx.conf /etc/nginx/
ADD bin /usr/local/bin

RUN set -ex \
 && mkdir -p tmp config public /mnt/shared/assets /mnt/shared/packs \
 && ln -s database.deploy.yml config/database.yml \
 && ln -s /mnt/shared/assets  public/assets \
 && ln -s /mnt/shared/packs  public/packs \
 && cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
