#!/bin/bash

# Create users and databases
function initialize_bpms_database {

  echo "Creating BPMS databases..."  

  mysql $mysql_flags <<EOSQL
    GRANT ALL ON *.* TO 'jboss'@'localhost' IDENTIFIED BY 'jboss';
    GRANT ALL ON *.* TO 'jboss'@'%' IDENTIFIED BY 'jboss';
    CREATE DATABASE IF NOT EXISTS bpmswb;
    CREATE DATABASE IF NOT EXISTS bpmskieserver;
    CREATE DATABASE IF NOT EXISTS bpmsadmin;
EOSQL

  for DATABASE in bpmswb bpmskieserver bpmsadmin
  do
    mysql $mysql_flags $DATABASE < $CONTAINER_SCRIPTS_PATH/sql/mysql5-jbpm-schema.sql
    mysql $mysql_flags $DATABASE < $CONTAINER_SCRIPTS_PATH/sql/quartz_tables_mysql.sql
    mysql $mysql_flags $DATABASE < $CONTAINER_SCRIPTS_PATH/sql/mysql5-dashbuilder-schema.sql
  done
}

