FROM jboss-base-7/jdk8:1.3

ENV FIS_JAVA_IMAGE_NAME="jboss-fuse-6/fis-java-openshift" \
    FIS_JAVA_IMAGE_VERSION="2.0" \
    FIS_JAVA_IMAGE_RELEASE="3" \
    JOLOKIA_VERSION="1.3.5.redhat-1" \
    PATH=$PATH:"/usr/local/s2i" \
    AB_JOLOKIA_PASSWORD_RANDOM="true" \
    AB_JOLOKIA_AUTH_OPENSHIFT="true" \
    JAVA_DATA_DIR="/deployments/data"

# Some version information
LABEL name="$FIS_JAVA_IMAGE_NAME" \
      version="$FIS_JAVA_IMAGE_VERSION" \
      release="$FIS_JAVA_IMAGE_RELEASE" \
      architecture="x86_64" \
      summary="Platform for building and running plain Java applications" \
      description="Platform for building and running plain Java applications (fat-jar and flat classpath)" \
      com.redhat.component="jboss-fuse-6-tech-fis-java-openshift-docker" \
      io.fabric8.s2i.version.maven="3.3.3-1.el7" \
      io.fabric8.s2i.version.jolokia="$JOLOKIA_VERSION" \
      io.k8s.description="JPlatform for building and running plain Java applications (fat-jar and flat classpath)" \
      io.k8s.display-name="Fuse Integration Services - Java" \
      io.openshift.tags="builder,java" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      io.openshift.s2i.destination="/tmp" \
      org.jboss.deployments-dir="/deployments"

# Temporary switch to root
USER root

# Use /dev/urandom to speed up startups.
RUN echo securerandom.source=file:/dev/urandom >> /usr/lib/jvm/java/jre/lib/security/java.security

# Add jboss user to the root group
RUN usermod -g root -G jboss jboss

# Install Maven
RUN yum install -y centos-release-scl && \
    yum install -y rh-maven33-maven \
    && yum clean all \
    && ln -s /opt/rh/rh-maven33/root/bin/mvn /usr/local/bin/mvn 

# S2I scripts + README
COPY s2i /usr/local/s2i
RUN chmod 755 /usr/local/s2i/*
ADD README.md /usr/local/s2i/usage.txt

# Add run script as /opt/run-java/run-java.sh and make it executable
COPY scripts/run-java.sh scripts/debug-options scripts/container-limits scripts/java-default-options /opt/run-java/
RUN chmod 755 /opt/run-java/run-java.sh /opt/run-java/java-default-options /opt/run-java/container-limits /opt/run-java/debug-options

# Adding run-env.sh to set app dir
COPY scripts/run-env.sh /opt/run-java/run-env.sh
RUN chmod 755 /opt/run-java/run-env.sh

# Necessary to permit running with a randomised UID
RUN mkdir -p /deployments/data \
 && chmod -R "g+rwX" /deployments \
 && chown -R jboss:root /deployments

# S2I requires a numeric, non-0 UID. This is the UID for the jboss user in the base image
USER 400

RUN mkdir -p /home/jboss/.m2
COPY scripts/settings.xml /home/jboss/.m2/settings.xml

# Use the run script as default since we are working as an hybrid image which can be
# used directly to. (If we were a plain s2i image we would print the usage info here)
CMD [ "/usr/local/s2i/run" ]
