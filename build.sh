#!/bin/bash
set -e

BUILD_APT_PACKAGES="git unzip zip curl"
RUNTIME_APT_PACKAGES="python-pip"
RUNTIME_PIP_PACKAGES="awscli"

apt-get -qy update
apt-get -qy upgrade
apt-get -qy install $BUILD_APT_PACKAGES $RUNTIME_APT_PACKAGES

pip install --upgrade $RUNTIME_PIP_PACKAGES
aws --version

# using this (for now at least) because the maven version that comes with debian
# jessie is too old to compile kafka
curl -s "https://get.sdkman.io" | bash
source "/root/.sdkman/bin/sdkman-init.sh"
sdk version
sdk install java
sdk install maven
sdk install gradle

cd /opt
git clone https://github.com/apache/kafka kafka
cd kafka
sed -ie 's#"-Xlint:unsound-match"#"-Xlint:unsound-match","-Xmax-classfile-name","127"#' build.gradle
gradle
./gradlew installAll
rm -rf .git

cd /opt
git clone https://github.com/confluentinc/common confluentinc-common
cd confluentinc-common
mvn install -Dmaven.test.skip=true
rm -rf .git

cd /opt
git clone https://github.com/confluentinc/rest-utils confluentinc-rest-utils
cd confluentinc-rest-utils
mvn install -Dmaven.test.skip=true
rm -rf .git

cd /opt
git clone https://github.com/confluentinc/schema-registry confluentinc-schema-registry
cd confluentinc-schema-registry
mvn install -Dmaven.test.skip=true
rm -rf .git

cd /opt
git clone https://github.com/confluentinc/kafka-connect-storage-common kafka-connect-storage-common
cd kafka-connect-storage-common
mvn install package -Dmaven.test.skip=true
rm -rf .git

cd /opt
git clone https://github.com/confluentinc/kafka-connect-storage-cloud kafka-connect-storage-cloud
cd kafka-connect-storage-cloud
mvn package -Dmaven.test.skip=true
ln -s /opt/kafka-connect-storage-common/package-kafka-connect-storage-common/target/kafka-connect-storage-common-package-5.0.0-SNAPSHOT-package/share/java/kafka-connect-storage-common kafka-connect-s3/target/kafka-connect-s3-5.0.0-SNAPSHOT-package/share/java/kafka-connect-s3/kafka-connect-storage-common
rm -rf .git

# configure
sed -ie 's/^#networkaddress.cache.ttl=-1$/networkaddress.cache.ttl=30/' /root/.sdkman/candidates/java/current/jre/lib/security/java.security

sdk flush temp
sdk flush archives
sdk flush broadcast

cd /
rm -rf /root/.gradle /root/.m2
rm -rf /opt/confluentinc-common /opt/confluentinc-rest-utils /opt/confluentinc-schema-registry

groupadd -g 30010 -r connect
useradd -u 30010 --no-log-init -g connect connect

apt-get -qy remove --purge $BUILD_APT_PACKAGES
apt-get -qy autoremove --purge
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/*
