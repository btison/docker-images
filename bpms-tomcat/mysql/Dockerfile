FROM btison/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

ADD . /

# Modify permissons
RUN chmod 755 /create-schema.sh /start-container.sh

# Create schema
RUN /create-schema.sh

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]
