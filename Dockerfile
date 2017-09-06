# Kafka Connect pre-packaged with all the connectors we need

FROM confluentinc/cp-kafka-connect:3.3.0-1

ENV BUILD_PACKAGES="git maven"
ENV RUNTIME_PIP_PACKAGES="awscli"

RUN apt-get -qy update \
 && apt-get -qy upgrade \
 && apt-get -qy install $BUILD_PACKAGES \

 && pip install --upgrade $RUNTIME_PIP_PACKAGES \
 && aws --version \

 && git clone --recursive https://github.com/GoogleCloudPlatform/cloud-pubsub-kafka \
 && cd cloud-pubsub-kafka/kafka-connector \
 && sed -ie 's#<finalName>#<relocations><relocation><pattern>io.netty</pattern><shadedPattern>shaded.io.netty</shadedPattern></relocation><relocation><pattern>com.google</pattern><shadedPattern>shaded.com.google</shadedPattern></relocation></relocations><finalName>#' pom.xml \
 && mvn package \
 && cp target/cps-kafka-connector.jar /usr/share/java/kafka \
 && cd \
 && rm -rf cloud-pubsub-kafka \

 && apt-get -qy remove --purge $BUILD_PACKAGES \
 && apt-get -qy autoremove --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

COPY include/etc/confluent/docker /etc/confluent/docker
COPY include/etc/bigcommerce /etc/bigcommerce
