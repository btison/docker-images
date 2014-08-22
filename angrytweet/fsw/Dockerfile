FROM btison/fsw-rtgov

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Scripts and resources
ADD ./env.sh /env.sh
ADD ./configure-fsw.sh /configure-fsw.sh
ADD ./start-fsw.sh /start-fsw.sh
ADD ./configuration /configuration
ADD ./resources /resources

# Modify script permissions
RUN chmod 755 /configure-fsw.sh /start-fsw.sh

# Configure FSW script
RUN /configure-fsw.sh

# Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
