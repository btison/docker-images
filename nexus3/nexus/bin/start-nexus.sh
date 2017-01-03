#!/bin/bash

function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

TLS_KEYSTORE=keystore.jks
TLS_KEYSTORE_PASSWORD=password
TLS_KEYSTORE_ALIAS=nexus-certificate

FIRST_RUN=false

# first run
if [ ! -d "$NEXUS_DATA/etc" ]; then 
  FIRST_RUN=true
fi

# configure nexus
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $NEXUS_DATA/etc
  cp $CONTAINER_SCRIPTS_PATH/nexus.properties $NEXUS_DATA/etc 
fi

# set vm options
cp $CONTAINER_SCRIPTS_PATH/nexus.vmoptions $NEXUS_HOME/$NEXUS_ROOT/bin/

# replace IP address in nexus.properties
sed -r -i "s'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'$IPADDR'g" $NEXUS_DATA/etc/nexus.properties

# TLS/SSL setup
SKIP_TLS=false
if [ ! -f $NEXUS_HOME/$NEXUS_ROOT/etc/ssl/$TLS_KEYSTORE ]; then
  crt_files=( ${TLS_CRT} ${TLS_CRT_PASSWORD} )
  for crt_file in "${crt_files[@]}"; do
    if [ ! -f $NEXUS_SECRETS/$crt_file ]; then
      echo "TLS setup: $crt_file missing"
      SKIP_TLS=true
    fi
  done
  if [ ! "$SKIP_TLS" = "true" ]; then
    echo "Set up SSL/TLS"
    # import pkcs12 certificate into keystore
    keytool -importkeystore -destkeystore $NEXUS_HOME/$NEXUS_ROOT/etc/ssl/$TLS_KEYSTORE \
          -srckeystore $NEXUS_SECRETS/$TLS_CRT -srcstoretype pkcs12 \
          -srcalias $TLS_CRT_NAME -destalias $TLS_KEYSTORE_ALIAS -noprompt \
          -srcstorepass $(cat ${NEXUS_SECRETS}/${TLS_CRT_PASSWORD}) \
          -deststorepass $TLS_KEYSTORE_PASSWORD
    cp -f $CONTAINER_SCRIPTS_PATH/jetty-https.xml $NEXUS_HOME/$NEXUS_ROOT/etc/jetty/jetty-https.xml
    VARS=( TLS_KEYSTORE TLS_KEYSTORE_PASSWORD )
    for i in "${VARS[@]}"; do
      sed -i "s'@@${i}@@'${!i}'g" $NEXUS_HOME/$NEXUS_ROOT/etc/jetty/jetty-https.xml
    done
  fi
fi

dumpEnv

# launch configuration script
if [ "$FIRST_RUN" = "true" ]; then
  echo "launching nexus configuration script"
  nohup /usr/bin/configure-nexus.sh 0<&- &> $NEXUS_DATA/config.log &
fi 

# start nexus
# if `docker run` first argument start with `--` the user is passing nexus launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  # eval "exec java $NEXUS_OPTS $JAVA_OPTS -cp 'conf/:lib/*' org.sonatype.nexus.bootstrap.Launcher $LAUNCHER_CONF"
  $NEXUS_HOME/$NEXUS_ROOT/bin/nexus run
fi