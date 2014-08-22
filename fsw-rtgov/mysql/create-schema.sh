#!bin/bash
/usr/bin/mysqld_safe &
sleep 10s
mysql -u root -e "GRANT ALL ON *.* TO 'jboss'@'localhost' IDENTIFIED BY 'jboss';"
mysql -u root -e "GRANT ALL ON *.* TO 'jboss'@'%' IDENTIFIED BY 'jboss';"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS fsw"
mysql -u root -e "CREATE DATABASE IF NOT EXISTS rtgov"  

mysql -u root fsw < /sql/safe-guard-procedures.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/hibernate_sequence.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/riftsaw-dao-jpa-hibernate.ode-unit-test-embedded.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/riftsaw-dao-jpa.ode-bpel.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/riftsaw-dao-jpa.ode-scheduler.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/riftsaw-dao-jpa.ode-store.MySQL5InnoDBDialect.sql
mysql -u root fsw < /sql/jbpm-test.org.jbpm.persistence.jpa.MySQL5InnoDBDialect.sql

mysql -u root rtgov < /sql/safe-guard-procedures.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/hibernate_sequence.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/gadget-web.gadget-core.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/overlord-rtgov.overlord-rtgov-activity.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/overlord-rtgov-epn.overlord-rtgov-epn.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/import_rtgov.MySQL5InnoDBDialect.sql
mysql -u root rtgov < /sql/rtgov.MySQL5InnoDBDialect.sql
