#!/bin/bash

# Helper functions for sed 
# https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
#   quoteRe <text>
function quoteRe() { sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'; }

#  quoteSubst <text>
function quoteSubst() {
  IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$1")
  printf %s "${REPLY%$'\n'}"
}

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
    $EAP_HOME/$EAP_ROOT/bin/add-user.sh -u $user -p $password -s -sc $EAP_DATA/configuration
  else
    $EAP_HOME/$EAP_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $EAP_DATA/configuration
  fi
}

# Dump environment
function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
  echo "JBOSS_CONFIG: ${JBOSS_CONFIG}"
  echo "DEBUG_MODE: ${DEBUG_MODE}"
  echo "DEBUG_PORT: ${DEBUG_PORT}"
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

FIRST_RUN=false
CLEAN=false

# Standalone config file
JBOSS_CONFIG=standalone-docker.xml

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# First run?
if [ ! -d "$EAP_DATA/configuration" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# server opts
SERVER_OPTS=""

# relax restrictions on user passwords
sed -i "s/password.restriction=REJECT/password.restriction=RELAX/" $EAP_HOME/$EAP_ROOT/bin/add-user.properties

# first run : copy configuration, setup maven, setup datasources, create users
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $EAP_DATA/content

  # copy configuration
  echo "Copy configuration to $EAP_DATA"
  cp -r $EAP_HOME/$EAP_ROOT/standalone/configuration $EAP_DATA

  # copy standalone-docker.xml
  echo "Copy $JBOSS_CONFIG"
  cp -p --remove-destination $CONTAINER_SCRIPTS_PATH/standalone.xml $EAP_DATA/configuration/$JBOSS_CONFIG

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # create additional users
  for i in $(compgen -A variable | grep "^EAP_USER_");
  do
    IFS=':' read -a userArray <<< "${!i}"
    echo "Create user ${userArray[0]}"
    createUser ${userArray[0]} ${userArray[1]} ${userArray[2]} 
  done

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $EAP_HOME/$EAP_ROOT/standalone/data \
           $EAP_HOME/$EAP_ROOT/standalone/log \
           $EAP_HOME/$EAP_ROOT/standalone/tmp
fi

# append standalone.conf to bin/standalone.conf if needed
if ! grep -q "### Dynamic Resources ###" "$RHSSO_HOME/$RHSSO_ROOT/bin/standalone.conf"; then
  cat $CONTAINER_SCRIPTS_PATH/standalone.conf >> $RHSSO_HOME/$RHSSO_ROOT/bin/standalone.conf
fi

SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.management=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.insecure=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.node.name=server-$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.tx.node.id=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.config.dir=$EAP_DATA/configuration"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.deploy.dir=$EAP_DATA/content"
SERVER_OPTS="$SERVER_OPTS --server-config=$JBOSS_CONFIG"

# Set debug settings
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

dumpEnv

eval "exec $EAP_HOME/$EAP_ROOT/bin/standalone.sh $SERVER_OPTS \"\$@\""
