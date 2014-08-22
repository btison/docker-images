#!bin/bash
/usr/bin/mysqld_safe &
sleep 10s
mysql -u root -e "CREATE DATABASE IF NOT EXISTS angrytweet"
