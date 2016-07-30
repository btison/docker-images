FROM centos7/java8

ENV BPMS_HOME=/opt/jboss \
    BPMS_ROOT=bpms \
    BPMS_ROOT_ORIG=jboss-eap-6.4 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/bpms \
    BPMS_DATA=/opt/jboss/data \
    EAP_DISTRO=jboss-eap-6.4.7-full-build.zip \
    BPMS_DISTRO=jboss-bpmsuite-6.3.0.GA-redhat-4-deployable-eap6.x.zip

# Install unzip, mysql driver
RUN yum -y install unzip mysql-connector-java which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$EAP_DISTRO /tmp/resources/jboss-eap.zip
COPY resources/$BPMS_DISTRO /tmp/resources/jboss-bpmsuite.zip

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $BPMS_HOME && \
    mkdir -p $BPMS_DATA && \
    chown -R jboss:jboss $BPMS_HOME $BPMS_DATA && \
    chmod +x /usr/bin/run-bpms.sh && \
    chmod u+s `which ping`

USER jboss

# Install bpms
RUN unzip -q /tmp/resources/jboss-eap.zip -d $BPMS_HOME && \
    unzip -q -o /tmp/resources/jboss-bpmsuite.zip -d $BPMS_HOME && \
    mv $BPMS_HOME/$BPMS_ROOT_ORIG $BPMS_HOME/$BPMS_ROOT && \
    cp $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war/WEB-INF/lib/quartz-1.8.5.jar \
    $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib

CMD ["/usr/bin/run-bpms.sh"]
