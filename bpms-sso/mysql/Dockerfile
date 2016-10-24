FROM centos7/base

ENV HOME=/var/lib/mysql \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/mysql

RUN yum -y --setopt=tsflags=nodocs install mariadb-server gettext && \
    yum clean all && \
    mkdir -p /var/lib/mysql/data && \
    chown -R mysql.0 /var/lib/mysql && \
    test "$(id mysql)" = "uid=27(mysql) gid=27(mysql) groups=27(mysql)"

COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/

# Loosen permission bits for group to avoid problems running container with
# arbitrary UID
# When only specifying user, group is 0, that's why /var/lib/mysql must have
# owner mysql.0; that allows to avoid a+rwx for this dir
RUN chmod -R g+rwx /var/lib/mysql && \
    chmod +x /usr/bin/run-mysqld.sh

USER 27

# Entrypoint
CMD ["/usr/bin/run-mysqld.sh"]
