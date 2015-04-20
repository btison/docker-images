FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install mysql driver
RUN yum -y install unzip mysql-connector-java && \
    yum clean all

# Scripts
ADD . / 

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss && \
    chown -R jboss:jboss /opt/jboss && \
    chmod 755 /start-container.sh /install-fsw.sh /env.sh /start-fsw.sh /stop-fsw.sh

# Run installation script
RUN /install-fsw.sh

# Entrypoint
CMD ["/bin/bash", "/start-container.sh"]
