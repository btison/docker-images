FROM mattdm/fedora:f20

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

#perform updates
RUN yum -y update; yum clean all

#Install supervisor
RUN yum -y install supervisor; yum clean all

#create directories
RUN mkdir -p /var/run/supervisord

#Entrypoint
CMD true
