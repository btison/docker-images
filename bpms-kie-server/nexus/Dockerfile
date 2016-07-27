FROM centos7/java8

ENV NEXUS_HOME=/opt/nexus \
    NEXUS_VERSION=2.13.0-01 \
    NEXUS_DATA=/data \
    NEXUS_ROOT=nexus \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/nexus

# Install unzip
RUN yum -y install unzip && \
    yum clean all -y

# Copy files
COPY bin/start-nexus.sh /usr/bin/start-nexus.sh

COPY resources/nexus-$NEXUS_VERSION-bundle.zip /resources/nexus.zip

COPY container-scripts /usr/share/container-scripts/

# Create user nexus
RUN groupadd -r nexus -g 400 && useradd -u 400 -r -g nexus -d /opt/nexus -s /bin/bash -c "Nexus user" nexus

# Create installation directory and set permissions
RUN mkdir -p $NEXUS_HOME && \
    mkdir -p $NEXUS_DATA && \
    chown -R nexus:nexus $NEXUS_HOME $NEXUS_DATA && \
    chmod +x /usr/bin/start-nexus.sh

USER nexus

# Install nexus
RUN unzip -q /resources/nexus.zip -d $NEXUS_HOME && \
    mv $NEXUS_HOME/nexus-$NEXUS_VERSION $NEXUS_HOME/$NEXUS_ROOT

WORKDIR $NEXUS_HOME/$NEXUS_ROOT

CMD ["/usr/bin/start-nexus.sh"]