FROM f20/java

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
    chmod 755 /*.sh

# Run installation script
RUN /install-tomcat.sh

CMD ["/bin/bash", "/start-container.sh"]
