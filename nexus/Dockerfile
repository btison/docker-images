FROM f20/java

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Install unzip
RUN yum -y install unzip; yum clean all

# Copy files
ADD . /

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
RUN mkdir -p /opt/jboss && \
    chown -R jboss:jboss /opt/jboss && \
    chmod 755 /*.sh

# Run installation script
RUN /install-nexus.sh

# Expose port 8080
EXPOSE 8080

CMD ["/bin/bash", "/start-container.sh"]
