FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install unzip
RUN yum -y install unzip; yum clean all

# Copy files
ADD start-container.sh install-nexus.sh env.sh start-nexus.sh stop-nexus.sh /
ADD ./supervisord.conf /etc/
ADD resources /resources/

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss; chown -R jboss:jboss /opt/jboss

# Modify script permissions
RUN chmod 755 /start-container.sh /install-nexus.sh /env.sh /start-nexus.sh /stop-nexus.sh

# Install bpms script
RUN /install-nexus.sh

ENTRYPOINT ["/bin/bash", "/start-container.sh"]
