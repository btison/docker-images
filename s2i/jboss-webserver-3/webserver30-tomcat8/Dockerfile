FROM jboss-base-7/jdk8:1.3

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-webserver-3/webserver30-tomcat8" \
    JBOSS_IMAGE_VERSION="1.2" \
    JBOSS_IMAGE_RELEASE="dev" \
    JBOSS_PRODUCT="webserver" \
    JBOSS_WEBSERVER_VERSION="3.0.3" \
    PRODUCT_VERSION="3.0.3" \
    JWS_HOME="/opt/webserver" \
    CATALINA_OPTS="-Djava.security.egd=file:/dev/./urandom" \
    JPDA_ADDRESS="8000" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-webserver-3-webserver30-tomcat8-docker" \
      org.jboss.deployments-dir="/opt/webserver/webapps" \
      com.redhat.deployments-dir="/opt/webserver/webapps" \
      com.redhat.deployments-dir="/opt/webserver/webapps" \
      com.redhat.dev-mode="DEBUG:true" \
      com.redhat.dev-mode.port="JPDA_ADDRESS:8000"

# Exposed ports
EXPOSE 8080

USER root

# Install required RPMs
RUN yum install -y apr-util \
    && yum clean all

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY resources/jws-application-servers-3.0.3-RHEL7-x86_64.zip \
    /tmp/scripts/sources/

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
RUN [ "bash", "-x", "/tmp/scripts/jws-unpack-tomcat8/run" ]
RUN [ "bash", "-x", "/tmp/scripts/jws-chown/run" ]
RUN [ "bash", "-x", "/tmp/scripts/jws-debugging/run" ]
RUN [ "bash", "-x", "/tmp/scripts/jws-disable-ajp/run" ]


# Cleanup the scripts directory (after cct so cct has access to /tmp/scripts/sources)
RUN rm -rf /tmp/scripts

USER jboss

CMD ["/opt/webserver/bin/catalina.sh", "run"]