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

JAVA_OPTS=${JAVA_OPTS:-""}

# Nexus
NEXUS_IP=$(ping -q -c 1 -t 1 ${NEXUS_HOST} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
NEXUS_PORT=8080
NEXUS_URL=$NEXUS_IP:$NEXUS_PORT

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

if [ -n "$JAVA_APP_GAV" ]; then
  IFS=':' read -a gav <<< "${JAVA_APP_GAV}"
  if [ "${#gav[@]}" = "5" ]; then
    JAVA_APP_LIB=${gav[1]}-${gav[2]}-${gav[3]}.${gav[4]}
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&c=${gav[3]}&e=${gav[4]}"
  elif [ "${#gav[@]}" = "4" ]; then
    JAVA_APP_LIB=${gav[1]}-${gav[2]}.${gav[3]}
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&e=${gav[3]}"
  elif [ "${#gav[@]}" = "3" ]; then
    JAVA_APP_LIB=${gav[1]}-${gav[2]}.jar
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&e=jar"
  fi
  if [ ! -f $JAVA_APP_DIR/$JAVA_APP_LIB ]; then
    echo "Installing library ${JAVA_APP_LIB} in ${JAVA_APP_DIR}"
    curl --insecure -s -L -o $JAVA_APP_DIR/$JAVA_APP_LIB "$gav_url"  
  fi
fi

if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=$DEBUG_PORT,server=y,suspend=n"
fi

# max memory
# Check whether -Xmx is already given in JAVA_OPTS. Then we dont
# do anything here
if ! echo "${JAVA_OPTS}" | grep -q -- "-Xmx"; then
  MAX_HEAP=`get_heap_size`
  if [ -n "$MAX_HEAP" ]; then
    JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP}m"
  fi  
fi

# Make sure that we use /dev/urandom
JAVA_OPTS="${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom"

# system properties
for i in $(compgen -A variable | grep "^SYSTEM_PROP_"); do
  prop="${!i}"
  prop_resolved=$(eval echo $prop)
  echo "Adding property ${prop_resolved} to the system properties"
  JAVA_OPTS="$JAVA_OPTS ${prop_resolved}"
done

if [ -n "$JAVA_APP_GAV" ]; then
  cd $JAVA_APP_DIR
  echo "exec java $JAVA_OPTS -jar $JAVA_APP_LIB"
  exec java $JAVA_OPTS -jar $JAVA_APP_LIB
else
  echo "ERROR: No Java app specified"
fi