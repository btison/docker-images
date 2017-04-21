#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

sudo sysctl -w vm.max_map_count=262144

docker-compose -p zk -f $SCRIPT_DIR/docker-compose-zookeeper.yml up -d

sleep 15

docker-compose -p kafka -f $SCRIPT_DIR/docker-compose-kafka.yml up -d

docker-compose -p es -f $SCRIPT_DIR/docker-compose-es.yml up -d

sleep 15

docker-compose -p vertx -f $SCRIPT_DIR/docker-compose-vertx.yml up -d

docker-compose -p bke -f $SCRIPT_DIR/docker-compose-bpms.yml up -d

# Note:
# if es give s the following error at startup:
# ERROR: bootstrap checks failed
# max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
# execute the following command on the host:
# sudo sysctl -w vm.max_map_count=262144
