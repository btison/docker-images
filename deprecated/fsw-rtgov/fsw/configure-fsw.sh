#!/bin/bash

. /env.sh

# enable rtgov activity collection
echo "Enabling RTGov activity collection"
sed -i "s/collectionEnabled=false/collectionEnabled=true/" $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/overlord-rtgov.properties

# set rtgov server url
echo "Set RTGov server URL"
sed -i "s;RESTActivityServer.serverURL=.*;RESTActivityServer.serverURL=http://rtgov:8080;" $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/overlord-rtgov.properties

exit 0
