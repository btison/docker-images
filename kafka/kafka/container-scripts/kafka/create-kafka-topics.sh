#! /bin/bash

KAFKA_ZK_CONNECT=""
KAFKA_TOPICS=""

while [ "$#" -gt 0 ]
do
  case "$1" in
    --zookeeper)
        shift
        if [ -n "$1" ]; then
          KAFKA_ZK_CONNECT=$1
        fi           
        ;;
    --topics)
        shift
        if [ -n "$1" ]; then
          KAFKA_TOPICS=$1
        fi
        ;;
    --)
        shift
        break;;
    *)
        echo "invalid option $1"
        ;;
  esac
  shift
done

sleep 10

IFS=',' read -a topicArray <<< "${KAFKA_TOPICS}"
for i in "${topicArray[@]}"; do
  IFS=':' read -a topicDef <<< "${i}"
  TOPIC_NAME=${topicDef[0]}
  TOPIC_REPLICATION=${topicDef[1]}
  TOPIC_PARTITIONS=${topicDef[2]}
  echo "Create topic with name $TOPIC_NAME, replication # $TOPIC_REPLICATION, partitions # $TOPIC_PARTITIONS"
  $KAFKA_HOME/$KAFKA_ROOT/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZK_CONNECT --replication-factor $TOPIC_REPLICATION --partitions $TOPIC_PARTITIONS --if-not-exists --topic $TOPIC_NAME
done