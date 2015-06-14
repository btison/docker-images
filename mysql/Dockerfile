FROM centos7/base

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install mysql
RUN yum -y install mariadb-server && \
    yum clean all -y

# Init mysql
RUN mysql_install_db
RUN chown -R mysql:mysql /var/lib/mysql

# Add admin user
RUN /usr/bin/mysqld_safe & \
    sleep 10s && \
    echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'redhat' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

# Configure supervisor
ADD start-container.sh supervisord.conf /

# Expose port 3306
EXPOSE 3306

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]

