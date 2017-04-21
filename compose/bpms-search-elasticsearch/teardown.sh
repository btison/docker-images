#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

docker-compose -p bke -f $SCRIPT_DIR/docker-compose-bpms.yml down -v

docker-compose -p vertx -f $SCRIPT_DIR/docker-compose-vertx.yml down -v

docker-compose -p es -f $SCRIPT_DIR/docker-compose-es.yml down -v

docker-compose -p kafka -f $SCRIPT_DIR/docker-compose-kafka.yml down -v

docker-compose -p zk -f $SCRIPT_DIR/docker-compose-zookeeper.yml down -v

