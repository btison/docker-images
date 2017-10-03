FROM jboss-base-7/jdk8:1.3

# Environment variables
ENV JBOSS_IMAGE_NAME="redhat-openjdk-18/openjdk18-openshift" \
    JBOSS_IMAGE_VERSION="1.1" \
    MAVEN_VERSION="3.3.9-2.8.el7" \
    JOLOKIA_VERSION="1.3.6" \
    PATH="$PATH:"/usr/local/s2i"" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR="/deployments/data" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      architecture="x86_64" \
      com.redhat.component="redhat-openjdk-18-openjdk18-openshift-docker" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.fabric8.s2i.version.maven="3.3.9-2.8" \
      io.fabric8.s2i.version.jolokia="1.3.6" \
      io.k8s.description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Java Applications" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Exposed ports
EXPOSE 8080 8443 8778

USER root

# Install required RPMs
RUN yum install -y centos-release-scl && \
    yum install -y rh-maven33 \
    && yum clean all

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/s2i-common/install.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-java-misc/install_as_root" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-java-s2i/install_as_root" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-java-run/install_as_root" ]

USER root
RUN rm -rf /tmp/scripts

USER 400

CMD ["/usr/local/s2i/run"]