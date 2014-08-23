#!/bin/bash

__run_supervisor() {
echo "Running the run_supervisor function."
supervisord 
}

__run_script() {
echo "Running scripts"
echo MYSQL_HOST=${DB_PORT_3306_TCP_ADDR} >> /env.sh
}

# Call all functions
__run_script
__run_supervisor
