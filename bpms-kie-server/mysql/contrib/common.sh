#!/bin/bash

# Data directory where MySQL database files live. The data subdirectory is here
# because .bashrc and my.cnf both live in /var/lib/mysql/ and we don't want a
# volume to override it.
export MYSQL_DATADIR=/var/lib/mysql/data

export MYSQL_DEFAULTS_FILE=$HOME/my.cnf
export MYSQL_LOWER_CASE_TABLE_NAMES=${MYSQL_LOWER_CASE_TABLE_NAMES:-0}
export MYSQL_MAX_CONNECTIONS=${MYSQL_MAX_CONNECTIONS:-151}
export MYSQL_FT_MIN_WORD_LEN=${MYSQL_FT_MIN_WORD_LEN:-4}
export MYSQL_FT_MAX_WORD_LEN=${MYSQL_FT_MAX_WORD_LEN:-20}
export MYSQL_AIO=${MYSQL_AIO:-1}

# Initialize the MySQL database (create user accounts and the initial database)
function initialize_database() {
  echo 'Running mysql_install_db ...'
  mysql_install_db --datadir=$MYSQL_DATADIR
  
  start_local_mysql "$@"
  echo 'Creating admin user...'
mysql $mysql_flags <<EOSQL
    GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'redhat' WITH GRANT OPTION; FLUSH PRIVILEGES;
EOSQL
}

function start_local_mysql() {
  # Now start mysqld and add appropriate users.
  echo 'Starting local mysqld server ...'
  /usr/bin/mysqld_safe \
    --defaults-file=$MYSQL_DEFAULTS_FILE \
    --skip-networking --socket=/tmp/mysql.sock "$@" &
  mysql_pid=$!
  wait_for_mysql $mysql_pid
}

# Poll until MySQL responds to our ping.
function wait_for_mysql() {
  pid=$1 ; shift

  while [ true ]; do
    if [ -d "/proc/$pid" ]; then
      mysqladmin --socket=/tmp/mysql.sock ping &>/dev/null && return 0
    else
      return 1
    fi
    echo "Waiting for MySQL to start ..."
    sleep 1
  done
}
