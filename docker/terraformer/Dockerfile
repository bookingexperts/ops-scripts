FROM hashicorp/terraform

LABEL maintainer "arthur@bookingexperts.nl"

RUN set -ex \
  && apk --update add python3 \
  && apk --update add --virtual .build-dependencies python3-dev libffi-dev openssl-dev build-base \
  && pip3 install --no-cache --upgrade \
     requests \
     awscli \
     awsebcli \
     boto3 \
     cfn-flip \
     cfn-lint \
     PyYAML \
     sceptre \
  && apk del --purge .build-dependencies \
  && rm -rf /var/cache/apk/* /tmp/*

ADD bin /usr/local/bin

WORKDIR /root
ENTRYPOINT ["/usr/local/bin/tf"]
CMD ["apply"]
