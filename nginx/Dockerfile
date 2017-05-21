FROM centos7/base

EXPOSE 8080
EXPOSE 8443

ENV NGINX_CONFIGURATION_PATH=/opt/app-root/etc/nginx.d

RUN yum install -y yum-utils gettext hostname && \
    yum install -y centos-release-scl-rh epel-release && \
    INSTALL_PKGS="nss_wrapper bind-utils rh-nginx18 rh-nginx18-nginx" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

COPY ./contrib/ /opt/app-root
COPY ./bin /usr/bin/

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN sed -i -f /opt/app-root/nginxconf.sed /etc/opt/rh/rh-nginx18/nginx/nginx.conf && \
    mkdir -p /opt/app-root/etc/nginx.d/ && \
    chmod -R a+rwx /opt/app-root/etc && \
    chmod -R a+rwx /var/opt/rh/rh-nginx18 && \
    chmod -R a+rwx /usr/bin/run-nginx.sh && \
    chown -R 1001:0 /opt/app-root && \
    chown -R 1001:0 /var/opt/rh/rh-nginx18

USER 1001

VOLUME ["/opt/rh/rh-nginx18/root/usr/share/nginx/html"]
VOLUME ["/var/opt/rh/rh-nginx18/log/nginx/"]

ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable"

# Entrypoint
CMD ["/usr/bin/run-nginx.sh"]
