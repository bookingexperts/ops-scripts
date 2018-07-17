FROM alpine:3.8

LABEL maintainer "arthur@bookingexperts.nl"

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV='production'
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
    ruby \
    ruby-bundler \
    tzdata \
    yaml

ARG revision

COPY nginx.conf /etc/nginx/

RUN mkdir -p tmp config \
 && cd config \
 && ln -s database.deploy.yml database.yml \
 && cp /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
