#!/bin/bash
set -e

for VAR in `env`
do
  if [[ $VAR =~ ^CONNECT_ ]]; then
    prop_key=`echo "$VAR" | sed -r "s/(CONNECT_.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_key=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$prop_key=" /etc/bigcommerce/connect.distributed.properties; then
        sed -r -i "s@(^|^#)($prop_key)=(.*)@\2=${!env_key}@g" /etc/bigcommerce/connect.distributed.properties # note: no config values may contain an '@' char
    else
        echo "$prop_key=${!env_key}" >> /etc/bigcommerce/connect.distributed.properties
    fi
  fi

  if [[ $VAR =~ ^LOG4J_ ]]; then
    prop_key=`echo "$VAR" | sed -r "s/(LOG4J_.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_key=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$prop_key=" /etc/bigcommerce/log4j.properties; then
        sed -r -i "s@(^|^#)($prop_key)=(.*)@\2=${!env_key}@g" /etc/bigcommerce/log4j.properties # note: no config values may contain an '@' char
    else
        echo "$prop_key=${!env_key}" >> /etc/bigcommerce/log4j.properties
    fi
  fi
done
