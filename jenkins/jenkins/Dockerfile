FROM centos7/java8

ENV JENKINS_VERSION=2.46.3-1.1 \
    HOME=/var/lib/jenkins \
    JENKINS_HOME=/var/lib/jenkins \
    JENKINS_UC=https://updates.jenkins-ci.org

EXPOSE 8080 50000

# Jenkins LTS packages from
# https://pkg.jenkins.io/redhat-stable/
RUN curl https://pkg.jenkins.io/redhat-stable/jenkins.repo -o /etc/yum.repos.d/jenkins.repo && \
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins-ci.org.key && \
    yum install -y centos-release-scl-rh && \
    INSTALL_PKGS="rsync gettext git tar zip unzip jenkins-$JENKINS_VERSION" && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all  && \
    localedef -f UTF-8 -i en_US en_US.UTF-8

COPY ./contrib/bin /usr/local/bin
COPY ./contrib/jenkins /opt/jenkins

RUN chmod +x /usr/local/bin/run-jenkins.sh /usr/local/bin/fix-permissions /usr/local/bin/install-plugins.sh && \
    /usr/local/bin/install-plugins.sh /opt/jenkins/plugins.txt && \
    rmdir /var/log/jenkins && \
    chown -R jenkins:0 /opt/jenkins && \
    /usr/local/bin/fix-permissions /opt/jenkins && \
    /usr/local/bin/fix-permissions /var/lib/jenkins && \
    /usr/local/bin/fix-permissions /var/log

USER jenkins

CMD ["/usr/local/bin/run-jenkins.sh"]