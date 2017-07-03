# Kafka Connect pre-packaged all the JARs we need.

FROM confluentinc/cp-kafka-connect

ENV BUILD_PACKAGES="git maven"

RUN apt-get -y update \
 && apt-get -y install $BUILD_PACKAGES \


 && git clone --recursive https://github.com/GoogleCloudPlatform/cloud-pubsub-kafka \
 && pushd cloud-pubsub-kafka/kafka-connector \
 && mvn package \
 && cp target/cps-kafka-connector.jar /usr/share/java/kafka \
 && popd \
 && rm -rf cloud-pubsub-kafka \


 && apt-get -y remove --purge $BUILD_PACKAGES \
 && apt-get -y autoremove --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*
