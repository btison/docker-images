FROM jboss-base-7/base:1.3

ENV JBOSS_IMAGE_NAME="jboss-base-7/jdk8" \
    JBOSS_IMAGE_VERSION="1.3" \
    JBOSS_IMAGE_RELEASE="dev" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0" \
    JAVA_VENDOR="openjdk" \
    JAVA_VERSION="1.8.0"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-base-7-jdk8-docker"

# Install java
RUN yum -y install java-1.8.0-openjdk-devel && \
    yum clean all -y

# Entrypoint
CMD true