#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

echo "IPADDR = $IPADDR"

MYSQL_HOST_IP=$(ping -q -c 1 -t 1 mysql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
MYSQL_HOST_PORT=3306
NEXUS_IP=$(ping -q -c 1 -t 1 nexus | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
NEXUS_PORT=8080
NEXUS_URL=$NEXUS_IP:$NEXUS_PORT
BPMS_CONTROLLER_IP=$(ping -q -c 1 -t 1 bpms-wb | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "BPMS not installed."
  exit 0
fi

CLEAN=false
DEBUG_MODE=true
DEBUG_PORT="8787"
SERVER_OPTS=""
ADMIN_ONLY=""

while [ "$#" -gt 0 ]
do
    case "$1" in
      --debug)
          DEBUG_MODE=true
          shift
          if [ -n "$1" ] && [ "${1#*-}" = "$1" ]; then
              DEBUG_PORT=$1
          fi
          ;;
      --admin-only)
          ADMIN_ONLY=--admin-only
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
    rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/data $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/log $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/tmp
fi

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# configuration
if [ ! -d "$BPMS_DATA_DIR/configuration" ]; then
  mkdir -p $BPMS_DATA_DIR
  cp -r $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration $BPMS_DATA_DIR
  chown -R jboss:jboss $BPMS_DATA_DIR 
fi

# remove unwanted deployments
if [ ! "$BUSINESS_CENTRAL" == "true" ];
then
  echo "Removing business-central app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war.*
fi

if [ ! "$KIE_SERVER" == "true" ];
then
  echo "Removing kie_server app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war.*
fi

# setup nexus
sed -r -i "s'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}'$NEXUS_URL'g" $BPMS_DATA_DIR/configuration/$(basename $MAVEN_SETTINGS_XML)

# start bpms
sudo -u jboss \
    nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/standalone.sh -Djboss.bind.address=$IPADDR \
    -Djboss.bind.address.management=$IPADDR -Djboss.bind.address.insecure=$IPADDR \
    -Djboss.node.name=server-$IPADDR -Djboss.server.config.dir=$BPMS_DATA_DIR/configuration \
    -Dmysql.host.ip=$MYSQL_HOST_IP -Dmysql.host.port=$MYSQL_HOST_PORT -Dmysql.bpms.schema=$MYSQL_BPMS_SCHEMA \
    -Dorg.uberfire.nio.git.daemon.host=$IPADDR -Dorg.uberfire.nio.git.ssh.host=$IPADDR \
    --server-config=$JBOSS_CONFIG $ADMIN_ONLY $SERVER_OPTS 0<&- &>/dev/null &
echo "BPMS started"
 
