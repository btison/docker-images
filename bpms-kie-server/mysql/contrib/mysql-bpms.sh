#!/bin/bash

# Create users and databases
function initialize_bpms_database {

  echo "Creating BPMS databases..."  

mysql $mysql_flags <<EOSQL
    GRANT ALL ON *.* TO 'jboss'@'localhost' IDENTIFIED BY 'jboss';
    GRANT ALL ON *.* TO 'jboss'@'%' IDENTIFIED BY 'jboss';
    CREATE DATABASE IF NOT EXISTS bpmswb;
    CREATE DATABASE IF NOT EXISTS bpmskieserver;

EOSQL

  mysql $mysql_flags bpmswb < /sql/mysql5-jbpm-schema.sql
  mysql $mysql_flags bpmswb < /sql/quartz_tables_mysql.sql
  mysql $mysql_flags bpmswb < /sql/mysql5-dashbuilder-schema.sql

  mysql $mysql_flags bpmskieserver < /sql/mysql5-jbpm-schema.sql
  mysql $mysql_flags bpmskieserver < /sql/quartz_tables_mysql.sql
  mysql $mysql_flags bpmskieserver < /sql/mysql5-dashbuilder-schema.sql

}

