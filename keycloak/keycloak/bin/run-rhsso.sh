#!/bin/bash

# Helper function for creating users
function createUser() {
  user=$1
  password=$2
  realm=management
  if [ ! -z $3 ]
  then
    roles=$3
    realm=application
  fi

  if [ "$realm" == "management" ]
  then
    $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.sh -u $user -p $password -s -sc $RHSSO_DATA/configuration
  else
    $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $RHSSO_DATA/configuration
  fi
}

# Dump environment
function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
  echo "MYSQL_HOST_IP: ${MYSQL_HOST_IP}"
  echo "MYSQL_RHSSO_SCHEMA: ${MYSQL_RHSSO_SCHEMA}"
  echo "JBOSS_CONFIG: ${JBOSS_CONFIG}"
  echo "DEBUG_MODE: ${DEBUG_MODE}"
  echo "DEBUG_PORT: ${DEBUG_PORT}"
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
MYSQL_HOST_IP=$(ping -q -c 1 -t 1 mysql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
MYSQL_HOST_PORT=3306

FIRST_RUN=false
CLEAN=false

# Database
DATABASE=mysql
MYSQL_DRIVER=mysql-connector-java.jar
MYSQL_DRIVER_PATH=/usr/share/java
MYSQL_MODULE_NAME=com.mysql

# Standalone config file
JBOSS_CONFIG=standalone.xml

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# server options
SERVER_OPTS=""

# start options
RHSSO_OPTS=""

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# first run
if [ ! -d "$RHSSO_DATA/configuration" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

# relax restrictions on user passwords
sed -i "s/password.restriction=WARN/password.restriction=RELAX/" $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.properties

# configuration, only on first startup
if [ "$FIRST_RUN" = "true" ]; then
  # configure the datasource on the server
  echo "Configure the datasource"
  #replace placeholders in cli file
  cp $CONTAINER_SCRIPTS_PATH/rhsso.cli /tmp/rhsso.cli
  VARS=( MYSQL_MODULE_NAME MYSQL_DRIVER MYSQL_DRIVER_PATH JBOSS_CONFIG )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" /tmp/rhsso.cli
  done
  $RHSSO_HOME/$RHSSO_ROOT/bin/jboss-cli.sh --file=/tmp/rhsso.cli

  # copy configuration
  echo "Copy configuration to $RHSSO_DATA"
  mkdir -p $RHSSO_DATA
  mkdir -p $RHSSO_DATA/content
  cp -r $RHSSO_HOME/$RHSSO_ROOT/standalone/configuration $RHSSO_DATA

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # import admin user
  cp $CONTAINER_SCRIPTS_PATH/keycloak-add-user.json $RHSSO_DATA/configuration

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $RHSSO_HOME/$RHSSO_ROOT/standalone/data $RHSSO_HOME/$RHSSO_ROOT/standalone/log $RHSSO_HOME/$RHSSO_ROOT/standalone/tmp
fi

# start-up properties
if [ -n "$START_UP_PROPS" ]
then
  RHSSO_OPTS="$RHSSO_OPTS $(eval echo $START_UP_PROPS)"
fi

# start rhsso
if [ "$START_RHSSO" = "false" ] 
then
  exit 0
fi

SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.management=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.insecure=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.node.name=server-$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.config.dir=$RHSSO_DATA/configuration"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.deploy.dir=$RHSSO_DATA/content"
SERVER_OPTS="$SERVER_OPTS -Dmysql.host.ip=$MYSQL_HOST_IP"
SERVER_OPTS="$SERVER_OPTS -Dmysql.host.port=$MYSQL_HOST_PORT"
SERVER_OPTS="$SERVER_OPTS -Dmysql.rhsso.schema=$MYSQL_RHSSO_SCHEMA"
SERVER_OPTS="$SERVER_OPTS --server-config=$JBOSS_CONFIG"

# Set debug settings
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

dumpEnv

eval "exec $RHSSO_HOME/$RHSSO_ROOT/bin/standalone.sh $RHSSO_OPTS $SERVER_OPTS \"\$@\""