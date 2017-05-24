#!/bin/bash

# Helper function for creating users
function createUser() {
  user=$1
  password=$2
  realm=management
  if [ ! -z $3 ]; then
    realm=$3
  fi
  if [ ! -z $4 ]; then
    roles=$4
  fi
  if [ ! -z $5 ]; then
    file=$5 
  fi

  if [ "$realm" == "management" ]; then
    $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.sh -u $user -p $password -s -sc $RHSSO_DATA/configuration
  elif [ "$realm" == "application" ]; then
    $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $RHSSO_DATA/configuration
  else
    $RHSSO_HOME/$RHSSO_ROOT/bin/add-user.sh -u $user -p $password -s -r $realm -up $RHSSO_DATA/configuration/$file
  fi
}

# Dump environment
function dumpEnv() {
  echo "======================="
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
  echo "POSTGRESQL_HOST_IP: ${POSTGRESQL_HOST_IP}"
  echo "POSTGRESQL_RHSSO_SCHEMA: ${POSTGRESQL_RHSSO_SCHEMA}"
  echo "JBOSS_CONFIG: ${JBOSS_CONFIG}"
  echo "DEBUG_MODE: ${DEBUG_MODE}"
  echo "DEBUG_PORT: ${DEBUG_PORT}"
  echo "USE_TLS: $USE_TLS"
  if [ "$USE_TLS" = "true" ]; then
    echo "TLS_CA_CRT: $TLS_CA_CRT"
    echo "TLS_CRT: $TLS_CRT"
    echo "TLS_CRT_NAME: $TLS_CRT_NAME"
    echo "TLS_CRT_PASSWORD: $TLS_CRT_PASSWORD" 
  fi
  echo "======================="    
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
POSTGRESQL_HOST_IP=$(ping -q -c 1 -t 1 postgresql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
POSTGRESQL_HOST_PORT=5432

FIRST_RUN=false
CLEAN=false

# Database
DATABASE=postgresql
POSTGRESQL_DRIVER=postgresql-jdbc.jar
POSTGRESQL_DRIVER_PATH=/usr/share/java
POSTGRESQL_MODULE_NAME=com.postgresql

# Standalone config file
JBOSS_CONFIG=standalone-docker.xml

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# SSL/TLS options
TLS_REALM=https-realm
TLS_USERS=https-users.properties
TLS_KEYSTORE=rhsso.jks
TLS_KEYSTORE_ALIAS=rhsso-certificate

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

  # copy configuration
  echo "Copy configuration to $RHSSO_DATA"
  mkdir -p $RHSSO_DATA
  mkdir -p $RHSSO_DATA/content
  cp -r $RHSSO_HOME/$RHSSO_ROOT/standalone/configuration $RHSSO_DATA

  cp $RHSSO_DATA/configuration/standalone.xml $RHSSO_DATA/configuration/$JBOSS_CONFIG

  # configure the datasource on the server
  echo "Configure the datasource"
  #replace placeholders in cli file
  cp $CONTAINER_SCRIPTS_PATH/rhsso.cli /tmp/rhsso.cli
  VARS=( POSTGRESQL_MODULE_NAME JBOSS_CONFIG )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" /tmp/rhsso.cli
  done
  $RHSSO_HOME/$RHSSO_ROOT/bin/jboss-cli.sh -Djboss.server.config.dir=$RHSSO_DATA/configuration --file=/tmp/rhsso.cli

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # import admin user
  cp $CONTAINER_SCRIPTS_PATH/keycloak-add-user.json $RHSSO_DATA/configuration
  
  # TLS/SSL setup
  if [ "$USE_TLS" = "true" ]; then
    SKIP_TLS=false
    crt_files=( ${TLS_CRT} ${TLS_CRT_PASSWORD} ${TLS_CA_CRT} )
    for crt_file in "${crt_files[@]}"; do
      if [ ! -f $RHSSO_SECRETS/$crt_file ]; then
        echo "TLS setup: $crt_file missing"
        SKIP_TLS=true
      fi
    done
    if [ ! "$SKIP_TLS" = "true" ]; then
      echo "Set up SSL/TLS"
      TLS_KEYSTORE_PASSWORD=$(cat ${RHSSO_SECRETS}/${TLS_CRT_PASSWORD})
      # import pkcs12 certificate into keystore
      # WFCORE-1373: JBoss CLI embedded server does not recognize -Djboss.server.config.dir
      keytool -importkeystore -destkeystore $RHSSO_DATA/configuration/$TLS_KEYSTORE \
          -srckeystore $RHSSO_SECRETS/$TLS_CRT -srcstoretype pkcs12 \
          -srcalias $TLS_CRT_NAME -destalias $TLS_KEYSTORE_ALIAS -noprompt \
          -srcstorepass $(cat ${RHSSO_SECRETS}/${TLS_CRT_PASSWORD}) \
          -deststorepass $TLS_KEYSTORE_PASSWORD
      # import CA root certificate
      keytool -import -trustcacerts -alias root -file $RHSSO_SECRETS/$TLS_CA_CRT \
          -keystore $RHSSO_DATA/configuration/$TLS_KEYSTORE -noprompt \
          -storepass $TLS_KEYSTORE_PASSWORD
      # create user file for https realm
      touch $RHSSO_DATA/configuration/$TLS_USERS
      # setup security module
      cp $CONTAINER_SCRIPTS_PATH/tls.cli /tmp/tls.cli
      VARS=( JBOSS_CONFIG TLS_REALM TLS_USERS TLS_KEYSTORE TLS_KEYSTORE_PASSWORD TLS_KEYSTORE_ALIAS )
      for i in "${VARS[@]}"
      do
        sed -i "s'@@${i}@@'${!i}'g" /tmp/tls.cli
      done
      $RHSSO_HOME/$RHSSO_ROOT/bin/jboss-cli.sh -Djboss.server.config.dir=$RHSSO_DATA/configuration --file=/tmp/tls.cli

      # create admin user for https-realm
       createUser "admin" "admin" "$TLS_REALM" "" "$TLS_USERS"
    fi
  fi

  if [ -n "$(ls -A $RHSSO_IMPORT)" ]; then
    echo "Setting up rhsso for import" 
    RHSSO_OPTS="$RHSSO_OPTS -Dkeycloak.migration.action=import"
    RHSSO_OPTS="$RHSSO_OPTS -Dkeycloak.migration.provider=dir"
    RHSSO_OPTS="$RHSSO_OPTS -Dkeycloak.migration.strategy=OVERWRITE_EXISTING"
    RHSSO_OPTS="$RHSSO_OPTS -Dkeycloak.migration.dir=$RHSSO_IMPORT"
  fi

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $RHSSO_HOME/$RHSSO_ROOT/standalone/data $RHSSO_HOME/$RHSSO_ROOT/standalone/log $RHSSO_HOME/$RHSSO_ROOT/standalone/tmp
fi

# set up postgresql module
POSTGRESQL_MODULE_DIR=$(echo $POSTGRESQL_MODULE_NAME | sed 's@\.@/@g')
POSTGRESQL_MODULE=$RHSSO_HOME/$RHSSO_ROOT/modules/$POSTGRESQL_MODULE_DIR/main
if [ ! -d $POSTGRESQL_MODULE ];
then
  echo "Setup postgresql module"
  mkdir -p $POSTGRESQL_MODULE
  cp -rp $CONTAINER_SCRIPTS_PATH/$DATABASE-module.xml $POSTGRESQL_MODULE/module.xml
  #replace placeholders in module file
  VARS=( POSTGRESQL_MODULE_NAME POSTGRESQL_DRIVER )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $POSTGRESQL_MODULE/module.xml
  done
  ln -s $POSTGRESQL_DRIVER_PATH/$POSTGRESQL_DRIVER $POSTGRESQL_MODULE/$POSTGRESQL_DRIVER
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
SERVER_OPTS="$SERVER_OPTS -Dpostgresql.host.ip=$POSTGRESQL_HOST_IP"
SERVER_OPTS="$SERVER_OPTS -Dpostgresql.host.port=$POSTGRESQL_HOST_PORT"
SERVER_OPTS="$SERVER_OPTS -Dpostgresql.rhsso.schema=$POSTGRESQL_RHSSO_SCHEMA"
SERVER_OPTS="$SERVER_OPTS --server-config=$JBOSS_CONFIG"

# Set debug settings
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

dumpEnv

eval "exec $RHSSO_HOME/$RHSSO_ROOT/bin/standalone.sh $RHSSO_OPTS $SERVER_OPTS \"\$@\""