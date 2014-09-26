FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install mysql driver
RUN yum -y install unzip mysql-connector-java; yum clean all

# Scripts
ADD ./install-rtgov.sh /install-rtgov.sh
ADD ./env.sh /env.sh
ADD ./resources /resources
ADD ./configuration /configuration
ADD ./start-container.sh /start-container.sh
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start-rtgov.sh /start-rtgov.sh
ADD ./stop-rtgov.sh /stop-rtgov.sh
ADD ./copy-environment-variables.sh /copy-environment-variables.sh

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss
RUN chown -R jboss:jboss /opt/jboss

# Modify script permissions
RUN chmod 755 /start-container.sh /install-rtgov.sh /env.sh /start-rtgov.sh /stop-rtgov.sh /copy-environment-variables.sh

# Install FSW script
RUN /install-rtgov.sh

# Cleanup
RUN rm -rf /resources /configuration

# Expose ports 8080,9990,9999
EXPOSE 8080 9990 9999

# Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
