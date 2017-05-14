#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

pushd $SCRIPT_DIR/compose/nexus
docker-compose -p nexus up -d
popd
