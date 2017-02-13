#!/bin/sh
set -e

SCRIPT_DIR=$(dirname $0)
ADDED_DIR=${SCRIPT_DIR}/added
SOURCES_DIR=/tmp/scripts/sources/

# Configure logging
# (TODO: Move org/jboss/logmanager/ext from "base" to "openshift" layer, and override org/jboss/logging as we do for modules above)
cp -p ${ADDED_DIR}/logging.properties ${JBOSS_HOME}/standalone/configuration/
mkdir -p ${JBOSS_HOME}/modules/system/layers/base/org/jboss/logmanager/ext/main/
cp -p ${SOURCES_DIR}/javax.json-1.0.4.jar ${JBOSS_HOME}/modules/system/layers/base/org/jboss/logmanager/ext/main/
cp -p ${SOURCES_DIR}/jboss-logmanager-ext-1.0.0.Alpha2-redhat-1.jar ${JBOSS_HOME}/modules/system/layers/base/org/jboss/logmanager/ext/main/
sed -i 's|org.jboss.logmanager|org.jboss.logmanager.ext|' ${JBOSS_HOME}/modules/system/layers/base/org/jboss/logging/main/module.xml
