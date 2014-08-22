FROM btison/fsw

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Scripts
ADD ./configure-fsw.sh /configure-fsw.sh

# Modify script permissions
RUN chmod 755 /configure-fsw.sh

# Configure FSW script
RUN /configure-fsw.sh

# Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
