#!bin/bash
/usr/bin/mysqld_safe &
sleep 10s
mysql -u root -e "GRANT ALL ON *.* TO 'jboss'@'localhost' IDENTIFIED BY 'jboss';"
mysql -u root -e "GRANT ALL ON *.* TO 'jboss'@'%' IDENTIFIED BY 'jboss';"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS bpms"   
