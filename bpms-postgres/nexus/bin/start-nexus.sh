#!/bin/bash

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

MAX_HEAP=768m
MIN_HEAP=256m
JAVA_OPTS="-server -Djava.net.preferIPv4Stack=true"
JAVA_OPTS="$JAVA_OPTS -Xms${MIN_HEAP} -Xmx${MAX_HEAP}"
LAUNCHER_CONF="./conf/jetty.xml ./conf/jetty-requestlog.xml"
NEXUS_OPTS="-Dnexus-work=$NEXUS_DATA -Dapplication-port=8080 -Dapplication-host=$IPADDR"

dumpEnv

# start nexus
# if `docker run` first argument start with `--` the user is passing nexus launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  eval "exec java $NEXUS_OPTS $JAVA_OPTS -cp 'conf/:lib/*' org.sonatype.nexus.bootstrap.Launcher $LAUNCHER_CONF"
fi
