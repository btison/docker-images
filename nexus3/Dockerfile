FROM centos7/java8

ENV NEXUS_HOME=/opt/nexus \
    NEXUS_VERSION=3.2.0-01 \
    NEXUS_DATA=/data \
    NEXUS_ROOT=nexus \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/nexus \
    NEXUS_SECRETS=/opt/secrets

# Install unzip
RUN yum -y install tar curl && \
    yum clean all -y

# Copy files
COPY bin/start-nexus.sh /usr/bin/start-nexus.sh
COPY bin/configure-nexus.sh /usr/bin/configure-nexus.sh

COPY resources/nexus-$NEXUS_VERSION-unix.tar.gz /resources/nexus.tar.gz

COPY container-scripts /usr/share/container-scripts/

# Create user nexus
RUN groupadd -r nexus -g 400 && useradd -u 400 -r -g nexus -d /opt/nexus -s /bin/bash -c "Nexus user" nexus

# Create installation directory and set permissions
RUN mkdir -p $NEXUS_HOME && \
    mkdir -p $NEXUS_DATA && \
    chown -R nexus:nexus $NEXUS_HOME $NEXUS_DATA && \
    chmod +x /usr/bin/start-nexus.sh /usr/bin/configure-nexus.sh && \
    mkdir -p $NEXUS_SECRETS

USER nexus

# Install nexus
RUN tar -zxf /resources/nexus.tar.gz -C $NEXUS_HOME && \
    mv $NEXUS_HOME/nexus-$NEXUS_VERSION $NEXUS_HOME/$NEXUS_ROOT

WORKDIR $NEXUS_HOME/$NEXUS_ROOT

CMD ["/usr/bin/start-nexus.sh"]
