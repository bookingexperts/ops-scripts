FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

ENV RAILS_ENV='production' \
    BUNDLE_GITHUB__HTTPS=true \
    PATH="/opt/passenger/bin:$PATH"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENTRYPOINT ["bundle", "exec"]
CMD ["passenger", "start", "--nginx-config-template", "/opt/nginx.conf.erb", "--port", "8080"]

EXPOSE 8080

RUN set -ex \
 # Install dependecies
 && apk add --update --upgrade --no-cache --virtual .run-deps \
    dumb-init \
    file \
    git \
    imagemagick \
    less \
    libpq \
    libstdc++ \
    libsodium \
    nodejs \
    postgresql-client \
    ruby-bundler \
    ruby-full \
    tzdata \
    yaml \
    procps \
    curl \
    pcre \
    libstdc++ \
    libexecinfo \
 # install Build tools
 && apk add --update --upgrade --no-cache --virtual .build-deps \
    postgresql-dev \
    build-base \
    ruby-dev \
    linux-headers \
    curl-dev \
    pcre-dev \
    libexecinfo-dev \
    ca-certificates \
    wget \
    zlib-dev \
 # Build PGRepack
 && update-ca-certificates \
 && wget https://api.pgxn.org/dist/pg_repack/1.4.3/pg_repack-1.4.3.zip \
 && unzip pg_repack-1.4.3.zip \
 && cd pg_repack-1.4.3 \
 && make install \
 # Build passenger
 # download and extract
 && mkdir -p /opt \
 && curl -L https://www.phusionpassenger.com/latest_stable_tarball | tar -xzf - -C /opt \
 && mv /opt/passenger-* /opt/passenger \
 && export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo' \
# compile agent
 && passenger-config compile-agent --auto --optimize \
 && passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 \
 && passenger-config build-native-support \
# Cleanup passenger src directory
 && rm -rf /tmp/* \
 && mv /opt/passenger/src/ruby_supportlib /tmp \
 && mv /opt/passenger/src/nodejs_supportlib /tmp \
 && mv /opt/passenger/src/helper-scripts /tmp \
 && rm -rf /opt/passenger/src/* \
 && mv /tmp/* /opt/passenger/src/ \
 # Cleanup
 && cd .. \
 && passenger-config validate-install --auto \
 && apk del .build-deps \
 && rm -rf \
    /root/.gem \
    /root/.bundle \
    ./vendor/bundle/ruby/*/cache \
    ./pg_repack-* \
    /var/cache/apk/* \
    /opt/passenger/doc \
    /tmp/*

COPY nginx.conf.erb /opt
COPY bin /usr/local/bin/

RUN set -ex \
 && mkdir -p tmp config public /mnt/shared/assets \
 && ln -s database.deploy.yml config/database.yml \
 && ln -s /mnt/shared/assets  public/assets \
 && cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
