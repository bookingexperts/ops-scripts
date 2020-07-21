FROM hashicorp/terraform

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
  && apk --update add python3 jq py3-pip \
  && apk --update add --virtual .build-dependencies python3-dev libffi-dev openssl-dev build-base \
  && pip install --no-cache --upgrade \
     PyYAML \
     awscli \
     boto3 \
     cfn-flip \
     cfn-lint \
     requests \
  && apk del --purge .build-dependencies \
  && rm -rf /var/cache/apk/* /tmp/*

ADD bin /usr/local/bin

ENV AWS_DEFAULT_REGION=eu-central-1

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/tf"]
CMD ["apply"]
