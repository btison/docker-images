FROM btison/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

ADD ./create-schema.sh /create-schema.sh

#Modify permissons
RUN chmod 755 /create-schema.sh

RUN /create-schema.sh

#Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
