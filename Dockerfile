# Kafka Connect pre-packaged with all the connectors we need

FROM confluentinc/cp-kafka-connect

ENV BUILD_PACKAGES="git maven"
ENV RUNTIME_PIP_PACKAGES="awscli"

RUN apt-get -qy update \
 && apt-get -qy upgrade \
 && apt-get -qy install $BUILD_PACKAGES \

 && pip install --upgrade $RUNTIME_PIP_PACKAGES \
 && aws --version \

 && git clone --recursive https://github.com/GoogleCloudPlatform/cloud-pubsub-kafka \
 && cd cloud-pubsub-kafka/kafka-connector \
 && mvn package \
 && cp target/cps-kafka-connector.jar /usr/share/java/kafka \
 && cd \
 && rm -rf cloud-pubsub-kafka \

 && apt-get -qy remove --purge $BUILD_PACKAGES \
 && apt-get -qy autoremove --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* \

 && echo '/etc/bigcommerce/pre-configure' >> /etc/confluent/docker/apply-mesos-overrides

COPY include/etc/bigcommerce /etc/bigcommerce
