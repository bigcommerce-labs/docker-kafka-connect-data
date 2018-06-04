FROM debian:jessie-slim

COPY build.sh /opt/build.sh
RUN /opt/build.sh

# runtime files not required for build
COPY include/etc/confluent/docker /etc/confluent/docker
COPY include/etc/bigcommerce /etc/bigcommerce
