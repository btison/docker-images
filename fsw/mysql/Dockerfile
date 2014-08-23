FROM btison/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Add scripts
ADD ./sql /sql
ADD /create-schema.sh /create-schema.sh

# Change permissions
RUN chmod 755 /create-schema.sh

# Execute script
RUN /create-schema.sh

# Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
