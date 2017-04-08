FROM centos7/base

ENV HOME=/var/lib/pgsql \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql

RUN yum -y install gettext postgresql-server postgresql \
    postgresql-contrib && \
    yum clean all && \
    localedef -f UTF-8 -i en_US en_US.UTF-8 && \
    mkdir -p /var/lib/pgsql/data && \
    chown -R postgres.0 /var/lib/pgsql /var/run/postgresql && \
    chmod -R g+rw var/lib/pgsql /var/run/postgresql && \
    find var/lib/pgsql -type d -exec chmod g+x {} + && \
    find /var/run/postgresql -type d -exec chmod g+x {} + && \
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)"

COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/

RUN chmod +x /usr/bin/run-postgresql.sh

USER 26

CMD ["/usr/bin/run-postgresql.sh"]