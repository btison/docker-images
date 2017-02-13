FROM jboss-eap-6/eap64-openshift:1.5

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-kieserver-6/kieserver63-openshift" \
    JBOSS_IMAGE_VERSION="1.4" \
    JBOSS_IMAGE_RELEASE="dev" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-kieserver-6-kieserver63-openshift-docker" \
      io.k8s.description="Base platform for executing business rules and processes on JBoss BxMS KIE Server 6.3." \
      io.k8s.display-name="JBoss BxMS KIE Server 6.3" \
      io.openshift.tags="builder,kieserver,kieserver6"

# Exposed ports
EXPOSE 8778

USER root

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY \
    resources/jboss-bpmsuite-6.3.4.GA-deployable-eap6.x.zip \
    resources/jboss-bpmsuite-6.3.4.GA-supplementary-tools.zip \
    resources/openshift-kieserver-common-1.1.0.Final-redhat-1.jar \
    resources/openshift-kieserver-jms-1.1.0.Final-redhat-1.jar \
    resources/openshift-kieserver-web-1.1.0.Final-redhat-1.jar \
    /tmp/scripts/sources/

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/os-kieserver-launch/prepare.sh" ]

USER jboss
RUN [ "bash", "-x", "/tmp/scripts/os-kieserver-launch/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-kieserver-s2i/prepare.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-kieserver-webapp/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-kieserver-chmod/run" ]


# Cleanup the scripts directory (after cct so cct has access to /tmp/scripts/sources)
USER root
RUN rm -rf /tmp/scripts

USER jboss

CMD ["/opt/eap/bin/kieserver-launch.sh"]