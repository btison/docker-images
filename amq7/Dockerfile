FROM centos7/java8

ENV AMQ_HOME=/opt/amq \
    AMQ_ROOT=amq-broker \
    AMQ_ROOT_ORIG=amq-broker-7.1.0 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/amq \
    AMQ_DATA=/opt/amq/data \
    AMQ_DISTRO=amq-broker-7.1.0-bin.zip

# Install unzip
RUN yum -y install unzip which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY resources/$AMQ_DISTRO /tmp/resources/amq-broker.zip

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $AMQ_HOME && \
    mkdir -p $AMQ_DATA && \
    chown -R jboss:jboss $AMQ_HOME $AMQ_DATA && \
    chmod +x /usr/bin/run-amq.sh && \
    chmod u+s `which ping`

USER jboss

# Install amq
RUN unzip -q /tmp/resources/amq-broker.zip -d $AMQ_HOME && \
    mv $AMQ_HOME/$AMQ_ROOT_ORIG $AMQ_HOME/$AMQ_ROOT

CMD ["/usr/bin/run-amq.sh"]
