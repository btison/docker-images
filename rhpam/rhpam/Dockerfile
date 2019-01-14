FROM centos7/java8

# Install unzip, db driver
RUN yum -y install unzip postgresql-jdbc which && \
    yum clean all -y

ENV RHPAM_HOME=/opt/jboss \
    RHPAM_ROOT=rhpam \
    RHPAM_ROOT_ORIG=jboss-eap-7.1 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/rhpam \
    RHPAM_DATA=/opt/jboss/data \
    EAP_DISTRO=jboss-eap-7.1.4-full-build.zip \
    RHPAM_BC_DISTRO=rhpam-7.1.0-business-central-eap7-deployable.zip \
    RHPAM_KIESERVER_DISTRO=rhpam-7.1.0-kie-server-ee7.zip \
    RHPAM_CONTROLLER_DISTRO=rhpam-7.0-controller-ee7.zip

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$EAP_DISTRO /tmp/resources/jboss-eap.zip
COPY resources/$RHPAM_BC_DISTRO /tmp/resources/rhpam-bc.zip
COPY resources/$RHPAM_KIESERVER_DISTRO /tmp/resources/rhpam-kieserver.zip
COPY resources/$RHPAM_CONTROLLER_DISTRO /tmp/resources/rhpam-controller.zip

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $RHPAM_HOME && \
    mkdir -p $RHPAM_DATA && \
    chown -R jboss:jboss $RHPAM_HOME $RHPAM_DATA && \
    chmod +x /usr/bin/run-rhpam.sh /usr/bin/dynamic_resources.sh && \
    chmod u+s `which ping`

USER jboss

# Install rhpam
RUN unzip -q /tmp/resources/jboss-eap.zip -d $RHPAM_HOME && \
    unzip -q -o /tmp/resources/rhpam-bc.zip -d $RHPAM_HOME && \
    mv $RHPAM_HOME/$RHPAM_ROOT_ORIG $RHPAM_HOME/$RHPAM_ROOT && \
    chmod +x $RHPAM_HOME/$RHPAM_ROOT/bin/standalone.sh && \
    unzip -q /tmp/resources/rhpam-kieserver.zip -d $RHPAM_HOME && \
    mv $RHPAM_HOME/kie-server.war $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments && \
    rm -rf $RHPAM_HOME/SecurityPolicy/* && \
    unzip -q /tmp/resources/rhpam-controller.zip -d $RHPAM_HOME && \
    mv $RHPAM_HOME/controller.war $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments && \
    rm -rf $RHPAM_HOME/SecurityPolicy/*

CMD ["/usr/bin/run-rhpam.sh"]
