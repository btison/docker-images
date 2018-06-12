FROM centos7/java8

ENV RHDM_HOME=/opt/jboss \
    RHDM_ROOT=rhdm \
    RHDM_ROOT_ORIG=jboss-eap-7.1 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/rhdm \
    RHDM_DATA=/opt/jboss/data \
    EAP_DISTRO=jboss-eap-7.1.2-full-build.zip \
    RHDM_DC_DISTRO=rhdm-7.0.0.GA-decision-central-eap7-deployable.zip \
    RHDM_KIESERVER_DISTRO=rhdm-7.0.0.GA-kie-server-ee7.zip

# Install unzip, db driver
RUN yum -y install unzip which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$EAP_DISTRO /tmp/resources/jboss-eap.zip
COPY resources/$RHDM_DC_DISTRO /tmp/resources/rhdm-bc.zip
COPY resources/$RHDM_KIESERVER_DISTRO /tmp/resources/rhdm-kieserver.zip


# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $RHDM_HOME && \
    mkdir -p $RHDM_DATA && \
    chown -R jboss:jboss $RHDM_HOME $RHDM_DATA && \
    chmod +x /usr/bin/run-dm.sh /usr/bin/dynamic_resources.sh && \
    chmod u+s `which ping`

USER jboss

# Install rhdm
RUN unzip -q /tmp/resources/jboss-eap.zip -d $RHDM_HOME && \
    unzip -q -o /tmp/resources/rhdm-bc.zip -d $RHDM_HOME && \
    mv $RHDM_HOME/$RHDM_ROOT_ORIG $RHDM_HOME/$RHDM_ROOT && \
    chmod +x $RHDM_HOME/$RHDM_ROOT/bin/standalone.sh && \
    unzip -q /tmp/resources/rhdm-kieserver.zip -d $RHDM_HOME && \
    mv $RHDM_HOME/kie-server.war $RHDM_HOME/$RHDM_ROOT/standalone/deployments && \
    mv $RHDM_HOME/SecurityPolicy/* $RHDM_HOME/$RHDM_ROOT/bin

CMD ["/usr/bin/run-dm.sh"]