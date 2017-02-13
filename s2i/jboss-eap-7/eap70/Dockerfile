FROM jboss-base-7/jdk8:1.3

ENV JBOSS_IMAGE_NAME="jboss-eap-7/eap70" \
    JBOSS_IMAGE_VERSION="1.3" \
    JBOSS_IMAGE_RELEASE="dev" \
    LAUNCH_JBOSS_IN_BACKGROUND="true" \
    JBOSS_PRODUCT="eap" \
    JBOSS_EAP_VERSION="7.0.4.GA" \
    JBOSS_HOME="/opt/eap" \
    EAP_DISTRO=jboss-eap-7.0.4-full-build.zip \
    EAP_VERSION="7.0"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-eap-7-tech-preview-eap70-docker" \
      com.redhat.deployments-dir="/opt/eap/standalone/deployments" \
      com.redhat.dev-mode="DEBUG:true" \
      com.redhat.dev-mode.port="DEBUG_PORT:8787"

EXPOSE 8080

COPY resources/$EAP_DISTRO /tmp/scripts/sources/

RUN unzip -q /tmp/scripts/sources/$EAP_DISTRO && \
    mv jboss-eap-$EAP_VERSION $JBOSS_HOME && \
    chown -R jboss:root $JBOSS_HOME && \
    chmod 0755 $JBOSS_HOME && \
    chmod -R g+rwX $JBOSS_HOME && \
    rm -rf /tmp/scripts

USER jboss

CMD ["/opt/eap/bin/standalone.sh", "-b", "0.0.0.0"]