FROM btison/base

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

#Install mysql
RUN yum -y install mariadb-server; yum clean all

#Init mysql
RUN mysql_install_db
RUN chown -R mysql:mysql /var/lib/mysql

#Add admin user
RUN /usr/bin/mysqld_safe & \
    sleep 10s &&\
    echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'redhat' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

#configure supervisor
ADD supervisord.conf /etc/supervisord.conf
ADD start-container.sh /start-container.sh

#Expose port 3306
EXPOSE 3306

#Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]

