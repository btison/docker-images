FROM centos7/base

ENV GITLAB_VERSION=8.12.7 \
    RUBY_VERSION=2.3 \
    GOLANG_VERSION=1.5.3 \
    GITLAB_SHELL_VERSION=3.6.1 \
    GITLAB_WORKHORSE_VERSION=0.8.2 \
    GITLAB_USER="git" \
    GITLAB_HOME="/home/git" \
    GITLAB_LOG_DIR="/var/log/gitlab" \
    GITLAB_CACHE_DIR="/etc/docker-gitlab"

ENV GITLAB_INSTALL_DIR="${GITLAB_HOME}/gitlab" \
    GITLAB_SHELL_INSTALL_DIR="${GITLAB_HOME}/gitlab-shell" \
    GITLAB_WORKHORSE_INSTALL_DIR="${GITLAB_HOME}/gitlab-workhorse" \
    GITLAB_DATA_DIR="${GITLAB_HOME}/data" \
    GITLAB_BUILD_DIR="${GITLAB_CACHE_DIR}/build" \
    GITLAB_RUNTIME_DIR="${GITLAB_CACHE_DIR}/runtime"

RUN yum install -y --setopt=tsflags=nodocs \
      supervisor logrotate nginx openssh-server \
      wget git python python-docutils nodejs \
      libpqxx zlib libyaml gdbm readline redis \
      ncurses libffi libxml2 libxslt libcurl libicu \
      which sudo passwd tar initscripts cronie gettext && \
    yum clean all

COPY assets/build/install-ruby.sh ${GITLAB_BUILD_DIR}/install-ruby.sh
RUN chmod 755 ${GITLAB_BUILD_DIR}/install-ruby.sh && \
    ${GITLAB_BUILD_DIR}/install-ruby.sh

COPY assets/build/install.sh ${GITLAB_BUILD_DIR}/install.sh
RUN sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
    chmod 755 ${GITLAB_BUILD_DIR}/install.sh && \
    ${GITLAB_BUILD_DIR}/install.sh

COPY assets/runtime/ ${GITLAB_RUNTIME_DIR}/
COPY assets/entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

WORKDIR ${GITLAB_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
#CMD true