FROM centos7/java8

# Install unzip, mysql driver
RUN yum -y install unzip mysql-connector-java sudo jq && \
    yum clean all -y

# Copy files
ADD . /

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation directory and set permissions
# Sudo requires a tty
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers && \
    mkdir -p /opt/jboss && \
    chown -R jboss:jboss /opt/jboss && \
    chmod 755 /*.sh

# Run installation script
RUN /install-rhsso.sh

CMD ["/bin/bash", "/start-container.sh"]
