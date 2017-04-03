#! /bin/bash

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-1}
KAFKA_BROKER_PORT=${KAFKA_BROKER_PORT:-9092}
KAFKA_PARTITIONS=${KAFKA_PARTITIONS:-1}
KAFKA_TOPICS=${KAFKA_TOPICS:-""}

cp -f $CONTAINER_SCRIPTS_PATH/kafka-server.properties $KAFKA_HOME/$KAFKA_ROOT/config/server-$KAFKA_BROKER_ID.properties

# ZooKeeper Connect
ZK_CONNECT=""
for i in $(compgen -A variable | grep "^KAFKA_ZK_"); do
  IFS=':' read -a zkServerArray <<< "${!i}"

  SERVER_IPADDR=$(ping -q -c 1 -t 1 ${zkServerArray[0]} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)

  echo "Add Zookeeper server ${zkServerArray[0]} with IP address $SERVER_IPADDR"
  ZK_CONNECT="$ZK_CONNECT,$SERVER_IPADDR:${zkServerArray[1]}"
done
ZK_CONNECT="${ZK_CONNECT:1:${#ZK_CONNECT}-1}"

# Replace placeholders in config file
VARS=( KAFKA_BROKER_ID IPADDR KAFKA_BROKER_PORT KAFKA_LOG KAFKA_PARTITIONS ZK_CONNECT )
for i in "${VARS[@]}"
do
  sed -i "s'@@${i}@@'${!i}'g" $KAFKA_HOME/$KAFKA_ROOT/config/server-$KAFKA_BROKER_ID.properties
done

# Create topics
if [ ! -z "$KAFKA_TOPICS" ]; then
  $CONTAINER_SCRIPTS_PATH/create-kafka-topics.sh --zookeeper $ZK_CONNECT --topics $KAFKA_TOPICS &
fi

eval "exec $KAFKA_HOME/$KAFKA_ROOT/bin/kafka-server-start.sh $KAFKA_HOME/$KAFKA_ROOT/config/server-$KAFKA_BROKER_ID.properties"