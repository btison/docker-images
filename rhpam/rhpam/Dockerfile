FROM centos7/java8

ENV RHPAM_HOME=/opt/jboss \
    RHPAM_ROOT=rhpam \
    RHPAM_ROOT_ORIG=jboss-eap-7.1 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/rhpam \
    RHPAM_DATA=/opt/jboss/data \
    EAP_DISTRO=jboss-eap-7.1.1-full-build.zip \
    RHPAM_BC_DISTRO=rhba-7.0.0.ER-redhat-2-business-central-eap7-deployable.zip \
    RHPAM_KIESERVER_DISTRO=rhba-7.0.0.ER-redhat-2-kie-server-ee7.zip

# Install unzip, db driver
RUN yum -y install unzip postgresql-jdbc which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$EAP_DISTRO /tmp/resources/jboss-eap.zip
COPY resources/$RHPAM_BC_DISTRO /tmp/resources/rhpam-bc.zip
COPY resources/$RHPAM_KIESERVER_DISTRO /tmp/resources/rhpam-kieserver.zip


# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $RHPAM_HOME && \
    mkdir -p $RHPAM_DATA && \
    chown -R jboss:jboss $RHPAM_HOME $RHPAM_DATA && \
    chmod +x /usr/bin/run-bpms.sh /usr/bin/dynamic-resources.sh && \
    chmod u+s `which ping`

USER jboss

# Install bpms
RUN unzip -q /tmp/resources/jboss-eap.zip -d $RHPAM_HOME && \
    unzip -q -o /tmp/resources/rhpam-bc.zip -d $RHPAM_HOME && \
    mv $RHPAM_HOME/$RHPAM_ROOT_ORIG $RHPAM_HOME/$RHPAM_ROOT && \
    chmod +x $RHPAM_HOME/$RHPAM_ROOT/bin/standalone.sh && \
    unzip -q /tmp/resources/rhpam-kieserver.zip -d $RHPAM_HOME && \
    mv $RHPAM_HOME/kie-server.war $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments && \
    mv $RHPAM_HOME/SecurityPolicy/* $RHPAM_HOME/$RHPAM_ROOT/bin

CMD ["/usr/bin/run-bpms.sh"]
