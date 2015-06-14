FROM f20/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Add scripts
ADD . /

# Change permissions
RUN chmod 755 /*.sh

# Execute script
RUN /create-schema.sh

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]
