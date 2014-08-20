FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

#Install unzip
RUN yum -y install unzip

# Copy files
ADD ./start-container.sh /start-container.sh
ADD ./install-bpms.sh /install-bpms.sh
ADD ./env.sh /env.sh
ADD ./copy-environment-variables.sh /copy-environment-variables.sh
ADD ./start-bpms.sh /start-bpms.sh
ADD ./stop-bpms.sh /stop-bpms.sh
ADD ./supervisord.conf /etc/supervisord.conf
RUN mkdir /resources /configuration
ADD ./resources /resources
ADD ./configuration /configuration

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss
RUN chown -R jboss:jboss /opt/jboss

# Modify script permissions
RUN chmod 755 /start-container.sh /install-bpms.sh /env.sh /copy-environment-variables.sh /start-bpms.sh /stop-bpms.sh

# Install bpms script
RUN /install-bpms.sh

# Cleanup
RUN rm -rf /resources

#Expose port 8080,9990,9999
EXPOSE 8080 9990 9999

ENTRYPOINT ["/bin/bash", "/start-container.sh"]
