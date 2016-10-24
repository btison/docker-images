#!/bin/bash

set -eu

source "${CONTAINER_SCRIPTS_PATH}/common.sh"
source "${CONTAINER_SCRIPTS_PATH}/mysql-bpms.sh"
source "${CONTAINER_SCRIPTS_PATH}/mysql-keycloak.sh"

# Process the MySQL configuration files
echo 'Processing MySQL configuration files ...'
envsubst < ${CONTAINER_SCRIPTS_PATH}/my.cnf.template > $MYSQL_DEFAULTS_FILE

if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
  initialize_database "$@"
  initialize_bpms_database
  initialize_keycloak_database
  shutdown_local_mysql
fi

# Restart the MySQL server with public IP bindings
unset_env_vars
echo 'Running final exec -- Only MySQL server logs after this point'
exec /usr/bin/mysqld_safe --defaults-file=$MYSQL_DEFAULTS_FILE "$@" 2>&1
