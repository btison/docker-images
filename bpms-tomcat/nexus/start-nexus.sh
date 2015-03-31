#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
export NEXUS_APPLICATION_HOST=$IPADDR
export NEXUS_APPLICATION_PORT=$NEXUS_PORT
export NEXUS_WORK=/data/nexus

echo "IPADDR = $IPADDR"
echo "NEXUS_APPLICATION_HOST = $NEXUS_APPLICATION_HOST"
echo "NEXUS_APPLICATION_PORT = $NEXUS_APPLICATION_PORT"

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Nexus not installed."
  exit 0
fi

# start nexus
su jboss <<EOF
nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/nexus start 0<&- &>/dev/null &
EOF
echo "Nexus started"
 
