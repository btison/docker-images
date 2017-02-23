#!/bin/bash

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR=/tmp/scripts/sources/

unzip -o $SOURCES_DIR/rh-sso-7.0.0-eap6-adapter.zip -d $JBOSS_HOME
unzip -o $SOURCES_DIR/rh-sso-7.0.0-saml-eap6-adapter.zip -d $JBOSS_HOME

chown -R jboss:root $JBOSS_HOME
chmod -R g+rwX $JBOSS_HOME

