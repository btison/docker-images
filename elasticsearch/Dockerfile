FROM centos7/java8

ENV ES_HOME=/opt/es \
    ES_ROOT=es-server \
    ES_VERSION=5.3.0 \
    ES_DATA=/opt/es/data \
    ES_CONF=/opt/es/conf \
    CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/elasticsearch \
    ES_VERSION=5.3.0

RUN yum -y install tar && \
    yum clean all -y

# Copy files
COPY bin/run-es.sh /usr/bin/run-es.sh
COPY container-scripts /usr/share/container-scripts/
COPY resources/elasticsearch-$ES_VERSION.tar.gz /tmp/resources/elasticsearch.tar.gz

# Create user es
RUN groupadd -r es -g 400 && useradd -u 400 -r -g es -d /opt/es -s /bin/bash -c "EleaticSearch user" es

# Create installation directory and set permissions
RUN mkdir -p $ES_HOME $ES_DATA $ES_CONF && \
    chown -R es:es $ES_HOME $ES_DATA $ES_CONF && \
    chmod +x /usr/bin/run-es.sh

USER es

# Install zookeeper
RUN tar -zxf /tmp/resources/elasticsearch.tar.gz -C $ES_HOME && \
    mv $ES_HOME/elasticsearch-$ES_VERSION $ES_HOME/$ES_ROOT

CMD ["/usr/bin/run-es.sh"]