#! /bin/bash

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

eval "exec $ZK_HOME/$ZK_ROOT/bin/zkServer.sh start-foreground $ZK_HOME/$ZK_ROOT/conf/zoo.cfg \"\$@\""