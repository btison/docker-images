FROM centos7/base

ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/openldap

RUN yum -y install nss-pam-ldapd openldap-servers openldap-clients && \
    yum clean all -y

COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/

RUN chmod +x /usr/bin/run-openldap.sh

# dir for certificates and imports
RUN mkdir -p /opt/secrets && \
    mkdir -p /opt/openldap/import

# Entrypoint
ENTRYPOINT ["/usr/bin/run-openldap.sh"]