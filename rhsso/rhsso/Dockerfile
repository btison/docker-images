FROM centos7/java8

ENV RHSSO_HOME=/opt/jboss \
    RHSSO_ROOT=rhsso \
    RHSSO_ROOT_ORIG=rh-sso-7.2 \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/rhsso \
    RHSSO_DATA=/opt/jboss/data \
    RHSSO_DISTRO=rh-sso-7.2.0.zip \
    RHSSO_IMPORT=/opt/jboss/import \
    RHSSO_SECRETS=/opt/secrets

# Install unzip, mysql driver
RUN yum -y install unzip postgresql-jdbc which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/$RHSSO_DISTRO /tmp/resources/jboss-rhsso.zip

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $RHSSO_HOME && \
    mkdir -p $RHSSO_DATA && \
    chown -R jboss:jboss $RHSSO_HOME $RHSSO_DATA && \
    chmod +x /usr/bin/run-rhsso.sh && \
    chmod u+s `which ping` && \
    mkdir -p $RHSSO_IMPORT && \
    mkdir -p $RHSSO_SECRETS

USER jboss

# Install rhsso
RUN unzip -q /tmp/resources/jboss-rhsso.zip -d $RHSSO_HOME && \
    mv $RHSSO_HOME/$RHSSO_ROOT_ORIG $RHSSO_HOME/$RHSSO_ROOT
    
CMD ["/usr/bin/run-rhsso.sh"]
