#!/bin/bash

. env.sh

# Sanity Checks
if [ -f $NEXUS ];
then
    echo "File $NEXUS found"
else
    echo "File $NEXUS not found. Please put it in the resources folder"
    exit 255
fi

if [ -d $SERVER_INSTALL_DIR/$SERVER_NAME ] || [ -d $SERVER_INSTALL_DIR/$NEXUS_VERSION ]
then
  echo "Target directory already exists. Please remove it before installing Nexus again."
  exit 250
fi

# Install Nexus
echo "Unzipping Nexus"
unzip -q $NEXUS -d $SERVER_INSTALL_DIR

echo "Renaming the Nexus dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/$NEXUS_VERSION $SERVER_INSTALL_DIR/$SERVER_NAME

echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

exit 0
