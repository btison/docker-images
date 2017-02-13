FROM jboss-eap-7/eap70:1.3

ENV JBOSS_IMAGE_NAME="jboss-eap-7/eap70-openshift" \
    JBOSS_IMAGE_VERSION="1.5" \
    JBOSS_IMAGE_RELEASE="dev" \
    STI_BUILDER="jee"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-eap-7-eap70-openshift-docker" \
      io.k8s.description="Platform for building and running JavaEE applications on JBoss EAP 7.0" \
      io.k8s.display-name="JBoss EAP 7.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,javaee,eap,eap7" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"

EXPOSE 8443 8778

user root

RUN yum -y install mongodb24-mongo-java-driver postgresql-jdbc mysql-connector-java maven hostname && \
    yum clean all

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY \
    resources/javax.json-1.0.4.jar \
    resources/jboss-logmanager-ext-1.0.0.Alpha2-redhat-1.jar \
    resources/rh-sso-7.0.0-eap7-adapter.zip \
    resources/rh-sso-7.0.0-saml-eap7-adapter.zip \
    /tmp/scripts/sources/

COPY scripts /tmp/scripts

RUN chmod -R +x /tmp/scripts

# Run scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/dynamic-resources/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/s2i-common/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/java-alternatives/run.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap7-openshift/prepare.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-s2i/prepare.sh" ]

USER jboss
RUN [ "bash", "-x", "/tmp/scripts/os-eap7-openshift/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap7-modules/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-logging/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-launch/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap7-launch/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/jboss-maven/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-db-drivers/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-sso/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap70-sso/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-deployment-scanner/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-eap-extensions/configure.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/openshift-layer/configure_layers.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/openshift-layer/configure_passwd.sh" ]

RUN rm -rf /tmp/scripts

USER jboss

CMD ["/opt/eap/bin/openshift-launch.sh"]