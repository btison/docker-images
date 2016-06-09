#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

echo "IPADDR = $IPADDR"

MYSQL_HOST_IP=$(ping -q -c 1 -t 1 mysql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
MYSQL_HOST_PORT=3306

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "rh-sso not installed."
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

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# configuration
if [ ! -d "$RHSSO_DATA_DIR/configuration" ]; then
  mkdir -p $RHSSO_DATA_DIR
  mkdir -p $RHSSO_DATA_DIR/content
  cp -r $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration $RHSSO_DATA_DIR
  chown -R jboss:jboss $RHSSO_DATA_DIR
  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/data $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/log $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/tmp
fi

# start options
RHSSO_OPTS=""

# start-up properties
if [ -n "$START_UP_PROPS" ]
then
  RHSSO_OPTS="$RHSSO_OPTS $(eval echo $START_UP_PROPS)"
fi

# start bpms
if [ "$START_RHSSO" = "false" ] 
then
  exit 0
fi

sudo -u jboss \
    nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/standalone.sh \
    -Djboss.bind.address=$IPADDR \
    -Djboss.bind.address.management=$IPADDR \
    -Djboss.bind.address.insecure=$IPADDR \
    -Djboss.node.name=server-$IPADDR \
    -Djboss.server.config.dir=$RHSSO_DATA_DIR/configuration \
    -Djboss.server.deploy.dir=$RHSSO_DATA_DIR/content \
    -Dmysql.host.ip=$MYSQL_HOST_IP \
    -Dmysql.host.port=$MYSQL_HOST_PORT \
    -Dmysql.rhsso.schema=$MYSQL_RHSSO_SCHEMA \
    $RHSSO_OPTS \
    --server-config=$JBOSS_CONFIG $ADMIN_ONLY $SERVER_OPTS 0<&- &>/dev/null &
echo "BPMS started"