FROM jboss-eap-6/eap64:1.4

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-eap-6/eap64-openshift" \
    JBOSS_IMAGE_VERSION="1.5" \
    JBOSS_IMAGE_RELEASE="dev" \
    STI_BUILDER="jee" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-eap-6-eap64-openshift-docker" \
      io.k8s.description="Platform for building and running JavaEE applications on JBoss EAP 6.4" \
      io.k8s.display-name="JBoss EAP 6.4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,javaee,eap,eap6" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"

# Exposed ports
EXPOSE 8443 8778

USER root

# Install required RPMs
RUN yum install -y mongodb24-mongo-java-driver postgresql-jdbc mysql-connector-java maven hostname && \
    yum clean all

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY \
    resources/javax.json-1.0.4.jar \
    resources/jboss-logmanager-ext-1.0.0.Alpha2-redhat-1.jar \
    resources/rh-sso-7.0.0-eap6-adapter.zip \
    resources/rh-sso-7.0.0-saml-eap6-adapter.zip \
    /tmp/scripts/sources/

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/dynamic-resources/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/s2i-common/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/java-alternatives/run.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap64-openshift/prepare.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-s2i/prepare.sh" ]

USER jboss
RUN [ "bash", "-x", "/tmp/scripts/os-eap64-openshift/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap64-modules/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-logging/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-launch/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap64-launch/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/jboss-maven/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-db-drivers/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-sso/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap64-sso/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-deployment-scanner/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-extensions/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/openshift-layer/configure_layers.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/openshift-layer/configure_passwd.sh" ]


# Cleanup the scripts directory (after cct so cct has access to /tmp/scripts/sources)
RUN rm -rf /tmp/scripts

USER jboss

CMD ["/opt/eap/bin/openshift-launch.sh"]