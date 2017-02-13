FROM jboss-base-7/jdk8:1.3

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-eap-6/eap64" \
    JBOSS_IMAGE_VERSION="1.4" \
    JBOSS_IMAGE_RELEASE="dev" \
    LAUNCH_JBOSS_IN_BACKGROUND="true" \
    JBOSS_PRODUCT="eap" \
    JBOSS_EAP_VERSION="6.4.13.GA" \
    PRODUCT_VERSION="6.4.13.GA" \
    JBOSS_HOME="/opt/eap" \
    EAP_DISTRO=jboss-eap-6.4.13-full-build.zip \
    EAP_VERSION="6.4"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-eap-6-eap64-docker" \
      org.jboss.deployments-dir="/opt/eap/standalone/deployments" \
      com.redhat.deployments-dir="/opt/eap/standalone/deployments" \
      com.redhat.dev-mode="DEBUG:true" \
      com.redhat.dev-mode.port="DEBUG_PORT:8787"

# Exposed ports
EXPOSE 8080

USER root

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY resources/$EAP_DISTRO /tmp/scripts/sources/

RUN unzip -q /tmp/scripts/sources/$EAP_DISTRO && \
    mv jboss-eap-$EAP_VERSION $JBOSS_HOME && \
    chown -R jboss:root $JBOSS_HOME && \
    chmod 0755 $JBOSS_HOME && \
    chmod -R g+rwX $JBOSS_HOME && \
    rm -rf /tmp/scripts

USER jboss

CMD ["/opt/eap/bin/standalone.sh", "-b", "0.0.0.0"]