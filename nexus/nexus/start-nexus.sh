#!/bin/bash

. /env.sh

LOG=/start.log
echo "" > $LOG

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
export NEXUS_APPLICATION_HOST=$IPADDR
export NEXUS_APPLICATION_PORT=$NEXUS_PORT
export NEXUS_WORK=$NEXUS_DATA_DIR

echo "IPADDR = $IPADDR" >> $LOG
echo "NEXUS_APPLICATION_HOST = $NEXUS_APPLICATION_HOST" >> $LOG
echo "NEXUS_APPLICATION_PORT = $NEXUS_APPLICATION_PORT" >> $LOG

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Nexus not installed." >> $LOG
  exit 0
fi

# configure nexus
if [ ! -d "$NEXUS_DATA_DIR/conf" ]; then
  mkdir -p $NEXUS_DATA_DIR/conf
  cp -r $CONFIGURATION_DIR/nexus.xml $NEXUS_DATA_DIR/conf
  VARS=( NEXUS_VERSION )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $NEXUS_DATA_DIR/conf/nexus.xml	
  done
  chown -R jboss:jboss $NEXUS_DATA_DIR 	 
fi

# start nexus
su jboss <<EOF
nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/nexus start 0<&- &>/dev/null &
EOF
echo "Nexus started" >> $LOG
 
