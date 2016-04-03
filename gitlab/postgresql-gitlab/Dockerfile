FROM centos7/base

RUN yum -y install sudo postgresql-server postgresql \
    postgresql-contrib && \
    yum clean all

ADD ./postgresql-setup /usr/bin/postgresql-setup
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start_postgres.sh /start_postgres.sh
ADD ./postgresql.conf /postgresql.conf

# Sudo requires a tty. fix that.
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers && \
    chmod +x /usr/bin/postgresql-setup && \
    chmod +x /start_postgres.sh && \
    chown -v postgres.postgres /postgresql.conf

CMD ["/bin/bash", "/start_postgres.sh"]