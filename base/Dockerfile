FROM centos:7

# Perform updates, install supervisor
RUN yum -y install epel-release && \
    yum -y install supervisor && \
    yum -y install iproute && \
    yum clean all -y

# Create directory for supervisor
# RUN mkdir -p /var/run/supervisord

# Entrypoint
CMD true
