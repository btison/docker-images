FROM centos:7

ENV VERSION=0.9.97 \
    HOME=/app/gogs/data \
    PATH=/app/gogs:$PATH

RUN yum install -y --setopt=tsflags=nodocs epel-release && \
    yum install -y --setopt=tsflags=nodocs nss_wrapper gettext sqlite git && \
    yum clean all

RUN cd /opt && \
    curl -L https://github.com/gogits/gogs/releases/download/v${VERSION}/linux_amd64.tar.gz | tar xzv

COPY bin/start.sh /opt/gogs/start.sh
COPY container-scripts/gogs/build/ssh-hostkeygen container-scripts/gogs/build/start-gogs /opt/gogs/
COPY container-scripts/gogs/build/ssh-keygen /usr/bin/ssh-keygen

RUN mkdir -p /app/gogs /opt/gogs/custom/conf

# Create user git
RUN groupadd -r git -g 1000 && \
    useradd -u 1000 -g git -c "Gogs" -d $HOME -s /bin/bash git

RUN chown -R git:git /app/gogs/data && \
    chmod 777 /opt/gogs/custom /opt/gogs/custom/conf && \
    chmod +x /opt/gogs/start.sh

USER git

ENTRYPOINT ["/opt/gogs/start.sh"]

