#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

docker-compose -p nexus -f $SCRIPT_DIR/compose/nexus/docker-compose.yml up -d
