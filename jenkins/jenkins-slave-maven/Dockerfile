FROM centos7/java8

ENV HOME=/home/jenkins

RUN yum install -y centos-release-scl-rh && \
    INSTALL_PKGS="bc gettext git lsof rsync tar unzip which zip rh-maven33*" && \
    yum install -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V ${INSTALL_PKGS//\*/} && \
    yum clean all -y && \
    mkdir -p $HOME/.m2

# Copy the entrypoint
ADD contrib/bin/* /usr/local/bin/
ADD ./contrib/settings.xml $HOME/.m2/

RUN useradd -r -d /home/jenkins -s /bin/bash -c "Jenkins user" jenkins && \
    mkdir -p /home/jenkins && \
    chown -R jenkins:0 $HOME && \
    chmod -R g+w $HOME && \
    chmod 775 /etc/passwd && \
    chmod +x /usr/local/bin/run-jnlp-client /usr/local/bin/generate_container_user /usr/local/bin/configure-slave /usr/local/bin/scl_enable 

# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/local/bin/run-jnlp-client"]