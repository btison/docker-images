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

ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-2181}
ZK_QUORUM_PORT=${ZK_QUORUM_PORT:-2888}
ZK_LEADER_ELECTION_PORT=${ZK_LEADER_ELECTION_PORT:-3888}

FIRST_RUN=false

# First run?
if [ ! -f "$ZK_DATA/myid" ]; then 
  FIRST_RUN=true
  echo "First run"
fi


if [ "$FIRST_RUN" = "true" ]; then
  # create myid
  echo $ZK_ID > $ZK_DATA/myid
fi

cp -f $CONTAINER_SCRIPTS_PATH/zookeeper.cfg $ZK_HOME/$ZK_ROOT/conf/zoo.cfg

# replace placeholders in config file
VARS=( ZK_DATA ZK_CLIENT_PORT ZK_LOG )
for i in "${VARS[@]}"
do
  sed -i "s'@@${i}@@'${!i}'g" $ZK_HOME/$ZK_ROOT/conf/zoo.cfg
done

# set clientPortAddress
sed -r -i "s'^clientPortAddress=[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'clientPortAddress=$IPADDR'g" $ZK_HOME/$ZK_ROOT/conf/zoo.cfg

# set ensemble
# sleep 5 sec to make sure all other servers have been started
sleep 5
sed -i "/^server\./d" $ZK_HOME/$ZK_ROOT/conf/zoo.cfg
# set myself
echo "Add server $ZK_ID with IP address $IPADDR"
echo >> $ZK_HOME/$ZK_ROOT/conf/zoo.cfg
echo "server.$ZK_ID=$IPADDR:$ZK_QUORUM_PORT:$ZK_LEADER_ELECTION_PORT" >> $ZK_HOME/$ZK_ROOT/conf/zoo.cfg
# set other servers
for i in $(compgen -A variable | grep "^ZK_SERVER_"); do
  IFS=':' read -a zkServerArray <<< "${!i}"

  SERVER_IPADDR=$(ping -q -c 1 -t 1 ${zkServerArray[1]} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)

  echo "Add server ${zkServerArray[0]} with IP address $SERVER_IPADDR"
  echo "server.${zkServerArray[0]}=$SERVER_IPADDR:${zkServerArray[2]}:${zkServerArray[3]}" >> $ZK_HOME/$ZK_ROOT/conf/zoo.cfg

done

JAVA_OPTS=""
MAX_HEAP_DEFAULT=128m
MAX_HEAP=$(get_heap_size)
if [ -n "$MAX_HEAP" ]; then
  JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP}m"
else
  JAVA_OPTS="$JAVA_OPTS -Xmx${MAX_HEAP_DEFAULT}"
fi
echo "JAVA_OPTS: $JAVA_OPTS"
export JVMFLAGS=$JAVA_OPTS

eval "exec $ZK_HOME/$ZK_ROOT/bin/zkServer.sh start-foreground $ZK_HOME/$ZK_ROOT/conf/zoo.cfg \"\$@\""