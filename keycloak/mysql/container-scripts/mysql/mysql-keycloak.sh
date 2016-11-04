#!/bin/bash

# Create users and databases
function initialize_keycloak_database {

  echo "Creating RHSSO database..."  

mysql $mysql_flags <<EOSQL
    GRANT ALL ON *.* TO 'jboss'@'localhost' IDENTIFIED BY 'jboss';
    GRANT ALL ON *.* TO 'jboss'@'%' IDENTIFIED BY 'jboss';
    CREATE DATABASE IF NOT EXISTS keycloak;

EOSQL

}