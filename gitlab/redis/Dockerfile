FROM centos7/base

RUN yum -y install redis && \
    yum clean all

EXPOSE 6379

CMD [ "redis-server" ]