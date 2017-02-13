FROM jboss-kieserver-6/kieserver63-openshift:1.4

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-decisionserver-6/decisionserver63-openshift" \
    JBOSS_IMAGE_VERSION="1.4" \
    JBOSS_IMAGE_RELEASE="dev" \
    KIE_SERVER_BPM_DISABLED="true" \
    KIE_SERVER_BPM_UI_DISABLED="true" \
    KIE_SERVER_BRP_DISABLED="true" \
    JBOSS_PRODUCT="decisionserver" \
    JBOSS_DECISIONSERVER_VERSION="6.3.4.GA" \
    PRODUCT_VERSION="6.3.4.GA" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-decisionserver-6-decisionserver63-openshift-docker" \
      io.k8s.description="Platform for executing business rules on JBoss BRMS Realtime Decision Server 6.3." \
      io.k8s.display-name="JBoss BRMS Realtime Decision Server 6.3" \
      io.openshift.tags="builder,decisionserver,decisionserver6"

USER jboss