FROM btison/mysql

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

ADD create-schema.sh /
ADD supervisord.conf /etc/
ADD ./sql /sql

#Modify permissons
RUN chmod 755 /create-schema.sh /start-container.sh

RUN /create-schema.sh

#Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
