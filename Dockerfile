FROM debian:jessie-slim

COPY build.sh /opt/build.sh
RUN /opt/build.sh

# runtime files not required for build
COPY run.sh /opt/run.sh
COPY include/etc/bigcommerce /etc/bigcommerce

USER connect
CMD ["/opt/run.sh"]
