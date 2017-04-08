#!/bin/bash

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

function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

FIRST_RUN=false

# first run
if [ ! -d "$NEXUS_DATA/conf" ]; then 
  FIRST_RUN=true
fi

# configure nexus
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $NEXUS_DATA/conf
  cp -r $CONTAINER_SCRIPTS_PATH/nexus.xml $NEXUS_DATA/conf
  VARS=( NEXUS_VERSION )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $NEXUS_DATA/conf/nexus.xml	
  done	 
fi

JAVA_OPTS="-server -Djava.net.preferIPv4Stack=true"
MAX_HEAP_DEFAULT=768m
MAX_HEAP=$(get_heap_size)
MIN_HEAP=256m
if [ -n "$MAX_HEAP" ]; then
  JAVA_OPTS="$JAVA_OPTS -Xms${MAX_HEAP}m -Xmx${MAX_HEAP}m"
else
  JAVA_OPTS="$JAVA_OPTS -Xms${MIN_HEAP} -Xmx${MAX_HEAP_DEFAULT}"
fi
echo $JAVA_OPTS
LAUNCHER_CONF="./conf/jetty.xml ./conf/jetty-requestlog.xml"
NEXUS_OPTS="-Dnexus-work=$NEXUS_DATA -Dapplication-port=8080 -Dapplication-host=$IPADDR"

dumpEnv

# start nexus
# if `docker run` first argument start with `--` the user is passing nexus launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  eval "exec java $NEXUS_OPTS $JAVA_OPTS -cp 'conf/:lib/*' org.sonatype.nexus.bootstrap.Launcher $LAUNCHER_CONF"
fi