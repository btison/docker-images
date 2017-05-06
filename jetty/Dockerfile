FROM centos7/java8

ENV JETTY_INSTALL_DIR=/opt/jetty \
    JETTY_VERSION=9.3.19.v20170502 \
    JETTY_ROOT=jetty \
    JETTY_DEPLOY_DIR=/deployments

# Install unzip
RUN yum -y install unzip which && \
    yum clean all -y

# Copy files
COPY bin/run-jetty.sh /usr/bin/run-jetty.sh

COPY resources/jetty-distribution-$JETTY_VERSION.zip /resources/jetty.zip

# Create user jetty
RUN groupadd -r jetty -g 400 && useradd -u 400 -r -g jetty -d /opt/jetty -s /bin/bash -c "Jetty user" jetty

# Create installation directory and set permissions
RUN mkdir -p $JETTY_INSTALL_DIR $JETTY_DEPLOY_DIR && \
    chown -R jetty:jetty $JETTY_INSTALL_DIR $JETTY_DEPLOY_DIR && \
    chmod +x /usr/bin/run-jetty.sh

USER jetty

# Install Jetty
RUN unzip -q /resources/jetty.zip -d $JETTY_INSTALL_DIR && \
    mv $JETTY_INSTALL_DIR/jetty-distribution-$JETTY_VERSION $JETTY_INSTALL_DIR/$JETTY_ROOT

WORKDIR $JETTY_INSTALL_DIR/$JETTY_ROOT

CMD ["/usr/bin/run-jetty.sh"]