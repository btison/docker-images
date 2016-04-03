FROM centos7/base

RUN yum install -y logrotate nginx openssh-server \
    git ruby rubygems python python-docutils \
    libpqxx zlib libyaml gdbm readline redis \
    ncurses libffi libxml2 libxslt libcurl libicu rubygem-bundler \
    which sudo passwd tar initscripts cronie && \
    yum clean all

ADD config/setup/ /app/setup/

RUN sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    chmod 755 /app/setup/install

RUN /app/setup/install

COPY config/config/ /app/setup/config/
COPY config/init /app/init
RUN chmod 755 /app/init

# Entrypoint
ENTRYPOINT ["/app/init"]
CMD ["app:start"]