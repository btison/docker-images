FROM fedora:20

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Perform updates, install supervisor
RUN yum -y update && \
    yum -y install supervisor && \
    yum clean all -y

# Create directory for supervisor
RUN mkdir -p /var/run/supervisord

# Entrypoint
CMD true
