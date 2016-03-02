#!/bin/bash

source $HOME/common.sh
source $HOME/mysql-bpms.sh

set -eu

mysql_flags="-u root --socket=/tmp/mysql.sock"
admin_flags="--defaults-file=$MYSQL_DEFAULTS_FILE $mysql_flags"

cmd="$1"; shift

if [ "${cmd}" == "mysqld_safe" ]; then

  envsubst < ${MYSQL_DEFAULTS_FILE}.template > $MYSQL_DEFAULTS_FILE 
  
  if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
    initialize_database "$@"
    initialize_bpms_database
    
    echo "Shutting down local mysqld server..."
    mysqladmin $admin_flags flush-privileges shutdown    
  fi
  
  echo "Starting mysqld server..."
  exec /usr/bin/mysqld_safe --defaults-file=$MYSQL_DEFAULTS_FILE "$@" 2>&1
    
fi

exec $cmd "$@"
