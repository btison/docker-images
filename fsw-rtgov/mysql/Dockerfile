FROM btison/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Add scripts
ADD . /

# Change permissions
RUN chmod 755 /create-schema.sh /start-container

# Execute script
RUN /create-schema.sh

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]
