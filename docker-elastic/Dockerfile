FROM docker.elastic.co/elasticsearch/elasticsearch:5.5.2
MAINTAINER Arthur Holstvoogd <arthur@bookingexperts.nl>
ADD elasticsearch.yml /usr/share/elasticsearch/config/
USER root
RUN chown elasticsearch:elasticsearch config/elasticsearch.yml
USER elasticsearch
WORKDIR /usr/share/elasticsearch
RUN bin/elasticsearch-plugin install discovery-ec2
