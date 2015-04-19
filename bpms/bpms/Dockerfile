FROM btison/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install unzip, mysql driver
RUN yum -y install unzip mysql-connector-java && \
    yum clean all -y

# Copy files
ADD . /

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss && \
    chown -R jboss:jboss /opt/jboss && \
    chmod 755 /start-container.sh /install-bpms.sh /env.sh /start-bpms.sh /stop-bpms.sh

# Run installation script
RUN /install-bpms.sh

CMD ["/bin/bash", "/start-container.sh"]
