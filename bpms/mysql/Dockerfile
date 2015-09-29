FROM centos7/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

ADD . /

# Modify permissons
RUN chmod 755 /*.sh

# Create schema
RUN /create-schema.sh

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]
