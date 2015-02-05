FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install unzip, mysql driver
RUN yum -y install unzip mysql-connector-java; yum clean all

# Copy files
ADD ./start-container.sh /start-container.sh
ADD ./install-eap.sh /install-eap.sh
ADD ./env.sh /env.sh
ADD ./copy-environment-variables.sh /copy-environment-variables.sh
ADD ./start-eap.sh /start-eap.sh
ADD ./stop-eap.sh /stop-eap.sh
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
RUN chmod 755 /start-container.sh /install-eap.sh /env.sh /copy-environment-variables.sh /start-eap.sh /stop-eap.sh

# Install eap script
RUN /install-eap.sh

# Expose port 8080,9990,9999
EXPOSE 8080 9990 9999

ENTRYPOINT ["/bin/bash", "/start-container.sh"]
