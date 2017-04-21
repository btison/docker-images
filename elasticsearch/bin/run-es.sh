#! /bin/bash

function get_heap_size {
  CONTAINER_MEMORY_IN_BYTES=`cat /sys/fs/cgroup/memory/memory.limit_in_bytes`
  DEFAULT_MEMORY_CEILING=$((2**60-1))
  if [ "${CONTAINER_MEMORY_IN_BYTES}" -lt "${DEFAULT_MEMORY_CEILING}" ]; then
    if [ -z $CONTAINER_HEAP_PERCENT ]; then
      CONTAINER_HEAP_PERCENT=0.50
    fi

    CONTAINER_MEMORY_IN_MB=$((${CONTAINER_MEMORY_IN_BYTES}/1024**2))
    CONTAINER_HEAP_MAX=$(echo "${CONTAINER_MEMORY_IN_MB} ${CONTAINER_HEAP_PERCENT}" | awk '{ printf "%d", $1 * $2 }')

    echo "${CONTAINER_HEAP_MAX}"
  fi
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

ES_CLUSTER_NAME=${ES_CLUSTER_NAME:-es-cluster}
ES_NODE_NAME=${ES_NODE_NAME:-es-node}
ES_HTTP_PORT=${ES_HTTP_PORT:-9200}

FIRST_RUN=false

# First run?
if [ ! -f "$ES_CONF/elasticsearch.yml" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

if [ "$FIRST_RUN" = "true" ]; then
  cp -f $CONTAINER_SCRIPTS_PATH/elasticsearch.yml $ES_CONF/elasticsearch.yml
  cp -f $CONTAINER_SCRIPTS_PATH/jvm.options $ES_CONF/jvm.options
  cp -f $ES_HOME/$ES_ROOT/config/log4j2.properties $ES_CONF/log4j2.properties

  # replace placeholders in config file
  VARS=( IPADDR ES_CLUSTER_NAME ES_NODE_NAME ES_HTTP_PORT ES_DATA )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $ES_CONF/elasticsearch.yml
  done
fi

# ElasticSerch Discovery Hosts
ES_DISCOVERY_HOSTS="\"${IPADDR}\""
for i in $(compgen -A variable | grep "^ES_HOST_"); do
  IFS=':' read -a esHost <<< "${!i}"

  ES_HOST_IPADDR=$(ping -q -c 1 -t 1 ${esHost} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)

  echo "Add ElasticSearch doscovery host ${esHost} with IP address $ES_HOST_IPADDR"
  ES_DISCOVERY_HOSTS="$ES_DISCOVERY_HOSTS,\"$ES_HOST_IPADDR\""
done
sed -i "s'^discovery.zen.ping.unicast.hosts: \[.*\]'discovery.zen.ping.unicast.hosts: [${ES_DISCOVERY_HOSTS}]'g" $ES_CONF/elasticsearch.yml


ES_JAVA_XMS=""
ES_JAVA_XMX=""
MAX_HEAP_DEFAULT=${ES_MAX_HEAP:-1g}
MAX_HEAP=$(get_heap_size)
if [ -n "$MAX_HEAP" ]; then
  ES_JAVA_XMS=-Xms${MAX_HEAP}
  ES_JAVA_XMX=-Xmx${MAX_HEAP}
else
  ES_JAVA_XMS=-Xms${MAX_HEAP_DEFAULT}
  ES_JAVA_XMX=-Xmx${MAX_HEAP_DEFAULT}
fi
echo "JAVA_OPTS: $ES_JAVA_XMS, $ES_JAVA_XMX"
sed -r -i "s'^-Xms.*'$ES_JAVA_XMS'" $ES_CONF/jvm.options
sed -r -i "s'^-Xmx.*'$ES_JAVA_XMX'" $ES_CONF/jvm.options

# ES configuration: -Epath.conf=$ES_CONF
export ES_JVM_OPTIONS=$ES_CONF/jvm.options
eval "exec $ES_HOME/$ES_ROOT/bin/elasticsearch -Epath.conf=$ES_CONF \"\$@\""