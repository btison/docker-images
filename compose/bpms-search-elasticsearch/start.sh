#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

docker-compose -p zk -f $SCRIPT_DIR/docker-compose-zookeeper.yml up -d

sleep 15

docker-compose -p kafka -f $SCRIPT_DIR/docker-compose-kafka.yml up -d

sleep 15

docker-compose -p vertx -f $SCRIPT_DIR/docker-compose-vertx.yml up -d

docker-compose -p bke -f $SCRIPT_DIR/docker-compose-bpms.yml up -d
