#!/bin/sh
# Add default Maven settings with Red Hat/JBoss repositories
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added

mkdir -p $HOME/.m2
cp -p ${ADDED_DIR}/jboss-settings.xml $HOME/.m2/settings.xml

chown -R jboss:root $HOME/.m2
chmod -R g+rwX $HOME/.m2
