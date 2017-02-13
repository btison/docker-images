FROM centos7/base

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-base-7/base" \
    JBOSS_IMAGE_VERSION="1.3" \
    JBOSS_IMAGE_RELEASE="dev" \
    HOME="/home/jboss" \
    JAVA_TOOL_OPTIONS="-Duser.home=/home/jboss -Duser.name=jboss"

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-base-7-base-docker"

RUN yum -y install yum-utils unzip tar rsync && \
    yum clean all -y

RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -m -d /home/jboss -s /sbin/nologin -c "JBoss user" jboss

# Entrypoint
CMD true