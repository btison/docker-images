FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install unzip
RUN yum -y install unzip; yum clean all

# Copy files
ADD ./start-container.sh /start-container.sh
ADD ./install-nexus.sh /install-nexus.sh
ADD ./env.sh /env.sh
ADD ./start-nexus.sh /start-nexus.sh
ADD ./stop-nexus.sh /stop-nexus.sh
ADD ./supervisord.conf /etc/supervisord.conf
RUN mkdir /resources /configuration
ADD ./resources /resources

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss
RUN chown -R jboss:jboss /opt/jboss

# Modify script permissions
RUN chmod 755 /start-container.sh /install-nexus.sh /env.sh /start-nexus.sh /stop-nexus.sh

# Install bpms script
RUN /install-nexus.sh

# Cleanup
RUN rm -rf /resources

# Expose port 8080
EXPOSE 8080

ENTRYPOINT ["/bin/bash", "/start-container.sh"]
