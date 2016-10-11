FROM centos7/java8

ENV EAP_HOME=/opt/jboss \
    EAP_ROOT=eap \
    EAP_ROOT_ORIG=jboss-eap-7.0 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/eap \
    EAP_DATA=/opt/jboss/data \
    EAP_DISTRO=jboss-eap-7.0.2-full-build.zip

# Install unzip
RUN yum -y install unzip which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$EAP_DISTRO /tmp/resources/jboss-eap.zip

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $EAP_HOME && \
    mkdir -p $EAP_DATA && \
    chown -R jboss:jboss $EAP_HOME $EAP_DATA && \
    chmod +x /usr/bin/run-eap.sh && \
    chmod u+s `which ping`

USER jboss

# Install eap
RUN unzip -q /tmp/resources/jboss-eap.zip -d $EAP_HOME && \
    mv $EAP_HOME/$EAP_ROOT_ORIG $EAP_HOME/$EAP_ROOT

CMD ["/usr/bin/run-eap.sh"]
