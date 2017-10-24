# Kafka Connect pre-packaged with all the connectors we need

FROM confluentinc/cp-kafka-connect:3.3.0-1

ENV BUILD_PACKAGES="git maven"
ENV RUNTIME_PIP_PACKAGES="awscli"

RUN apt-get -qy update \
 && apt-get -qy upgrade \
 && apt-get -qy install $BUILD_PACKAGES \

 && pip install --upgrade $RUNTIME_PIP_PACKAGES \
 && aws --version \

 && sed -ie 's/^#networkaddress.cache.ttl=-1$/networkaddress.cache.ttl=30/' /usr/lib/jvm/zulu-8-amd64/jre/lib/security/java.security \

 && git clone --recursive https://github.com/GoogleCloudPlatform/cloud-pubsub-kafka \
 && cd cloud-pubsub-kafka/kafka-connector \
 && git status \
 && sed -ie 's#<finalName>#<relocations><relocation><pattern>io.netty</pattern><shadedPattern>shaded.io.netty</shadedPattern></relocation></relocations><finalName>#' pom.xml \
 && mvn package \
 && mkdir /usr/share/java/kafka-connect \
 && cp target/cps-kafka-connector.jar /usr/share/java/kafka-connect \
 && sed -ie 's#CLASSPATH="#CLASSPATH="/usr/share/java/kafka-connect/*:#' /etc/confluent/docker/launch \
 && cd \
 && rm -rf cloud-pubsub-kafka \

 && apt-get -qy remove --purge $BUILD_PACKAGES \
 && apt-get -qy autoremove --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

COPY include/etc/confluent/docker /etc/confluent/docker
COPY include/etc/bigcommerce /etc/bigcommerce
