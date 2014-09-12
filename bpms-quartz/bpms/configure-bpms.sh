#!/bin/bash

. env.sh

# Quartz Properties
echo "Copy quartz properties file"
cp $QUARTZ_PROPERTIES $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration

# Restore owner to jboss 
chown -R jboss:jboss $SERVER_INSTALL_DIR

# Configure the server
echo "Configure the Server"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.sh --admin-only -c $JBOSS_CONFIG &"
sleep 15
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_BPMS"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 \":shutdown\" "
sleep 10

exit 0
