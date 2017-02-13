FROM jboss-webserver-3/webserver30-tomcat8:1.2

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-webserver-3/webserver30-tomcat8-openshift" \
    JBOSS_IMAGE_VERSION="1.3" \
    JBOSS_IMAGE_RELEASE="dev" \
    STI_BUILDER="jee" 

# Labels
LABEL name="$JBOSS_IMAGE_NAME" \
      version="$JBOSS_IMAGE_VERSION" \
      release="$JBOSS_IMAGE_RELEASE" \
      architecture="x86_64" \
      com.redhat.component="jboss-webserver-3-webserver30-tomcat8-openshift-docker" \
      io.k8s.description="Platform for building and running web applications on JBoss Web Server 3.0 - Tomcat v8" \
      io.k8s.display-name="JBoss Web Server 3.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,tomcat8" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"

# Exposed ports
EXPOSE 8443 8778

USER root

# Install required RPMs
RUN yum -y install maven mongodb24-mongo-java-driver postgresql-jdbc mysql-connector-java && \
    yum clean all

# Add all required sources to the /tmp/scripts/sources/
# directory
COPY \
    resources/json-smart-1.1.1.jar \
    resources/commons-lang-2.6.0.redhat-4.jar \
    resources/jsonevent-layout-1.7-redhat-1.jar \
    /tmp/scripts/sources/

# Add scripts used to configure the image
COPY scripts /tmp/scripts

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/dynamic-resources/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/s2i-common/install.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/java-alternatives/run.sh" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-s2i/install_as_root" ]

USER jboss
RUN [ "bash", "-x", "/tmp/scripts/os-jws8-conffiles/run" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-jws-deployments/run" ]

USER jboss
RUN [ "bash", "-x", "/tmp/scripts/os-jws-deployments/run_as_jboss" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-db-drivers/run" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-logging/run" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-launch/run" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-https/run" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-secure-mgmt-console/run" ]
RUN [ "bash", "-x", "/tmp/scripts/os-jws-rm-root/run" ]
RUN [ "bash", "-x", "/tmp/scripts/jboss-maven/configure.sh" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/os-jws-chmod/run" ]
RUN [ "bash", "-x", "/tmp/scripts/openshift-layer/configure_passwd.sh" ]

# Cleanup the scripts directory (after cct so cct has access to /tmp/scripts/sources)
RUN rm -rf /tmp/scripts

USER jboss

CMD ["/opt/webserver/bin/launch.sh"]