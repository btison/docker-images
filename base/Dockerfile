FROM centos:7

# Perform updates, install epel, iproute
RUN yum -y install epel-release && \
    yum -y install iproute && \
    yum clean all -y

# Entrypoint
CMD true
