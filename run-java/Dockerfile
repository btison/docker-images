FROM centos7/java8

ENV JAVA_APP_DIR=/opt/java

RUN yum -y install which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/

# Create user jboss
RUN groupadd -r jboss -g 400 && useradd -u 400 -r -g jboss -d /opt/jboss -s /bin/bash -c "JBoss user" jboss

# Create installation and data directory and set permissions
RUN mkdir -p $JAVA_APP_DIR && \
    chown -R jboss:jboss $JAVA_APP_DIR && \
    chmod +x /usr/bin/run-java.sh && \
    chmod u+s `which ping`

USER jboss

CMD ["/usr/bin/run-java.sh"]