FROM ruby:alpine3.8

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
    yaml \
 # install Build tools
 && apk add --update --upgrade --no-cache --virtual .build-deps \
    build-base \
    ca-certificates \
    postgresql-dev \
    wget \
    zlib-dev \
 # Update rubygems & bundler
 && gem update --system --no-doc \
 && gem install bundler --no-doc \
 # Build PGRepack
 && update-ca-certificates \
 && wget https://api.pgxn.org/dist/pg_repack/1.4.3/pg_repack-1.4.3.zip \
 && unzip pg_repack-1.4.3.zip \
 && cd pg_repack-1.4.3 \
 && make install \
 # Cleanup
 && rm -rf \
    /root/.gem \
    /root/.bundle \
    ./vendor/bundle/ruby/*/cache \
    ./pg_repack-*

COPY nginx.conf /etc/nginx/
ADD bin /usr/local/bin

RUN set -ex \
 && mkdir -p tmp config public /mnt/shared/assets \
 && ln -s database.deploy.yml config/database.yml \
 && ln -s /mnt/shared/assets  public/assets \
 && cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
