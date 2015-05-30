#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

echo "IPADDR = $IPADDR"

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Tomcat not installed."
  exit 0
fi

CLEAN=false
DEBUG_MODE=false

while [ "$#" -gt 0 ]
do
    case "$1" in
      --debug)
          DEBUG_MODE=true
          ;;
      --clean)
          CLEAN=true
          ;; 
      --)
          shift
          break;;
      *)
          SERVER_OPTS="$SERVER_OPTS \"$1\""
          ;;
    esac
    shift
done

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/logs/*
fi

# Set debug settings if not already set
JPDA=""
JPDA_OPTS=""
if [ "$DEBUG_MODE" = "true" ]; then
    JPDA="jpda"
fi

# start bpms
su jboss <<EOF
${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/catalina.sh $JPDA start $SERVER_OPTS
EOF
 
