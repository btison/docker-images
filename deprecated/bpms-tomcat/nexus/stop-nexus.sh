#!/bin/bash

. /env.sh

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Nexus not installed."
  exit 0
fi

# start nexus
su jboss <<EOF
nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/nexus stop 0<&- &>/dev/null &
EOF
echo "Nexus stopped"
 
