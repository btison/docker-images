FROM centos7/java8

ENV ZK_HOME=/opt/zookeeper \
    ZK_ROOT=zk-server \
    ZK_DATA=/opt/zookeeper/zk-data \
    ZK_LOG=/opt/zookeeper/zk-log \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/zookeeper \
    ZK_VERSION=3.4.14

# Install packages
RUN yum -y install tar which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/zookeeper-$ZK_VERSION.tar.gz /tmp/resources/zookeeper.tar.gz

# Create user zookeeper
RUN groupadd -r zookeeper -g 400 && \
    useradd -r -u 400 -g zookeeper -c "ZooKeeper user" -d /opt/zookeeper -s /bin/bash zookeeper

# Create data and log dir
RUN mkdir -p $ZK_HOME && \
    mkdir -p $ZK_DATA && \
    mkdir -p $ZK_LOG && \
    chown -R zookeeper:zookeeper $ZK_HOME $ZK_DATA $ZK_LOG && \
    chmod +x /usr/bin/run-zk.sh && \
    chmod u+s `which ping`

USER zookeeper

# Install zookeeper
RUN tar -zxf /tmp/resources/zookeeper.tar.gz -C $ZK_HOME && \
    mv $ZK_HOME/zookeeper-$ZK_VERSION $ZK_HOME/$ZK_ROOT

CMD ["/usr/bin/run-zk.sh"]

