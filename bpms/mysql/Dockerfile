FROM centos7/base

ENV HOME=/var/lib/mysql

RUN yum -y --setopt=tsflags=nodocs install mariadb-server gettext && \
    yum clean all && \
    mkdir -p /var/lib/mysql/data && \
    chown -R mysql.0 /var/lib/mysql && \
    test "$(id mysql)" = "uid=27(mysql) gid=27(mysql) groups=27(mysql)"

COPY contrib /var/lib/mysql/
COPY run-*.sh /usr/local/bin/
ADD ./sql /sql

# Loosen permission bits for group to avoid problems running container with
# arbitrary UID
# When only specifying user, group is 0, that's why /var/lib/mysql must have
# owner mysql.0; that allows to avoid a+rwx for this dir
RUN chmod -R g+rwx /var/lib/mysql && \
    chmod 755 /usr/local/bin/run-*.sh

USER 27

# Entrypoint
ENTRYPOINT ["run-mysqld.sh"]
CMD ["mysqld_safe"]
