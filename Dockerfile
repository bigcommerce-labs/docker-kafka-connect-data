# Kafka Connect pre-packaged all the JARs we need

FROM confluentinc/cp-kafka-connect

ENV BUILD_PACKAGES="git maven"

RUN apt-get -qy update \
 && apt-get -qy install $BUILD_PACKAGES \


 && git clone --recursive https://github.com/GoogleCloudPlatform/cloud-pubsub-kafka \
 && cd cloud-pubsub-kafka/kafka-connector \
 && mvn package \
 && cp target/cps-kafka-connector.jar /usr/share/java/kafka \
 && cd \
 && rm -rf cloud-pubsub-kafka \


 && apt-get -qy remove --purge $BUILD_PACKAGES \
 && apt-get -qy autoremove --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*
