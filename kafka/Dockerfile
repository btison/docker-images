FROM centos7/java8

ENV KAFKA_HOME=/opt/kafka \
    KAFKA_ROOT=kafka-broker \
    KAFKA_LOG=/opt/kafka/kafka-log \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/kafka \
    KAFKA_VERSION=0.10.1.1

# Install packages
RUN yum -y install tar which && \
    yum clean all -y

# Copy files
COPY bin /usr/bin/
COPY container-scripts /usr/share/container-scripts/
COPY resources/kafka_2.11-$KAFKA_VERSION.tgz /tmp/resources/kafka.tgz

# Create user kafka
RUN groupadd -r kafka -g 400 && \
    useradd -r -u 400 -g kafka -c "Kafka user" -d /opt/kafka -s /bin/bash kafka

# Create directories
RUN mkdir -p $KAFKA_HOME && \
    mkdir -p $KAFKA_LOG && \
    chown -R kafka:kafka $KAFKA_HOME $KAFKA_LOG && \
    chmod +x /usr/bin/run-kafka.sh && \
    chmod +x /usr/share/container-scripts/kafka/*.sh && \
    chmod u+s `which ping`

USER kafka

# Install Kafka
RUN tar -zxf /tmp/resources/kafka.tgz -C $KAFKA_HOME && \
    mv $KAFKA_HOME/kafka_2.11-$KAFKA_VERSION $KAFKA_HOME/$KAFKA_ROOT

CMD ["/usr/bin/run-kafka.sh"]