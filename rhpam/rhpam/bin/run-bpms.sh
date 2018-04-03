#!/bin/bash

# Helper functions for sed 
# https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
#   quoteRe <text>
function quoteRe() { sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'; }

#  quoteSubst <text>
function quoteSubst() {
  IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$1")
  printf %s "${REPLY%$'\n'}"
}

# Helper function for creating users
function createUser() {
  user=$1
  password=$2
  realm=management
  if [ ! -z $3 ]
  then
    roles=$3
    realm=application
  fi

  if [ "$realm" == "management" ]
  then
    $RHPAM_HOME/$RHPAM_ROOT/bin/add-user.sh -u $user -p $password -s -sc $RHPAM_DATA/configuration
  else
    $RHPAM_HOME/$RHPAM_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $RHPAM_DATA/configuration
  fi
}

# Dump environment
function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo "IPADDR: ${IPADDR}"
  echo "PGSQL_HOST_IP: ${PGSQL_HOST_IP}"
  echo "NEXUS_IP: ${NEXUS_IP}"
  echo "BUSINESS_CENTRAL: ${BUSINESS_CENTRAL}"
  echo "BUSINESS_CENTRAL_DESIGN: ${BUSINESS_CENTRAL_DESIGN}"
  echo "KIE_SERVER: ${KIE_SERVER}"
  echo "PGSQL_RHPAM_SCHEMA: ${PGSQL_RHPAM_SCHEMA}"
  echo "JBOSS_CONFIG: ${JBOSS_CONFIG}"
  echo "QUARTZ: ${QUARTZ}"
  echo "MAVEN_SETTINGS: ${MAVEN_SETTINGS}"
  echo "DEBUG_MODE: ${DEBUG_MODE}"
  echo "DEBUG_PORT: ${DEBUG_PORT}"
  echo "EXECUTOR: ${EXECUTOR}"
  echo "EXECUTOR_JMS: ${EXECUTOR_JMS}"
  echo "EXECUTOR_POOL_SIZE: ${EXECUTOR_POOL_SIZE}"
  echo "EXECUTOR_RETRY_COUNT: ${EXECUTOR_RETRY_COUNT}"
  echo "EXECUTOR_INTERVAL: ${EXECUTOR_INTERVAL}"
  echo "EXECUTOR_TIMEUNIT: ${EXECUTOR_TIMEUNIT}"
  echo "RHPAM_DATASOURCE_POOL_MIN: ${RHPAM_DATASOURCE_POOL_MIN}"
  echo "RHPAM_DATASOURCE_POOL_MAX: ${RHPAM_DATASOURCE_POOL_MAX}"
  if [ "${KIE_SERVER}" = "true" ];then
    echo "KIE_SERVER_ID: ${KIE_SERVER_ID}"
    echo "KIE_SERVER_MANAGED: ${KIE_SERVER_MANAGED}"
    echo "RHPAM_EXT_DISABLED: ${RHPAM_EXT_DISABLED}"
    echo "RHDM_EXT_DISABLED: ${RHDM_EXT_DISABLED}"
    echo "BRP_EXT_DISABLED: ${BRP_EXT_DISABLED}"
    echo "JBPMUI_EXT_DISABLED: ${JBPMUI_EXT_DISABLED}"
    echo "KIE_SERVER_BYPASS_AUTH_USER: ${KIE_SERVER_BYPASS_AUTH_USER}"
  fi
  if [ -n "$KIE_SERVER_CONTROLLER_HOST" ];then
    echo "KIE_SERVER_CONTROLLER_IP: ${KIE_SERVER_CONTROLLER_IP}"
  fi
  if [ "$BUSINESS_CENTRAL" = "true" ];then
    echo "KIE_SERVER_CONTROLLER: ${KIE_SERVER_CONTROLLER}"
    echo "MAVEN_REPO: ${MAVEN_REPO}"
    echo "GIT_REPO: ${GIT_REPO}"
  fi
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
PGSQL_HOST_IP=$(ping -q -c 1 -t 1 postgresql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
PGSQL_HOST_PORT=5432
NEXUS_IP=$(ping -q -c 1 -t 1 ${NEXUS_HOST} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
NEXUS_PORT=8080
NEXUS_URL=$NEXUS_IP:$NEXUS_PORT
if [ -n "$KIE_SERVER_CONTROLLER_HOST" -a "$KIE_SERVER_CONTROLLER_HOST" = "local" ]; then
  KIE_SERVER_CONTROLLER_IP=$IPADDR
elif [ -n "$KIE_SERVER_CONTROLLER_HOST" ]; then
  echo "ping for kie server controller"
  KIE_SERVER_CONTROLLER_IP=$(ping -q -c 1 -t 1 ${KIE_SERVER_CONTROLLER_HOST} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
fi

FIRST_RUN=false
CLEAN=${CLEAN:-false}

# Database
DATABASE=postgresql
DATABASE_DIALECT=org.hibernate.dialect.PostgreSQLDialect
PGSQL_DRIVER=postgresql-jdbc.jar
PGSQL_DRIVER_PATH=/usr/share/java
PGSQL_MODULE_NAME=org.postgresql
RHPAM_DATASOURCE_POOL_MIN=${RHPAM_DATASOURCE_POOL_MIN:-0}
RHPAM_DATASOURCE_POOL_MAX=${RHPAM_DATASOURCE_POOL_MAX:-20}
RHPAM_DATASOURCE=jbpmDS
QUARTZ_DATASOURCE=quartzDS

# Standalone config file
JBOSS_CONFIG=standalone-docker.xml

# Maven settings
MAVEN_REPO=$RHPAM_DATA/m2/repository
MAVEN_SETTINGS=$RHPAM_DATA/configuration/settings.xml

# Git repo settings
GIT_REPO=$RHPAM_DATA/rhpam-repo

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# MDB Pools
MDB_MAX_POOL=${MDB_MAX_POOL:-16}

# Executor
EXECUTOR=${EXECUTOR:-true}
EXECUTOR_JMS=${EXECUTOR_JMS:-true}
EXECUTOR_POOL_SIZE=${EXECUTOR_POOL_SIZE:-1}
EXECUTOR_RETRY_COUNT=${EXECUTOR_RETRY_COUNT:-3}
EXECUTOR_INTERVAL=${EXECUTOR_INTERVAL:-3}
EXECUTOR_TIMEUNIT=${EXECUTOR_TIMEUNIT:-SECONDS}

MDB_EXECUTOR_MAX_SESSION=${MDB_EXECUTOR_MAX_SESSION:-16}

# Kie Examples
KIE_EXAMPLE=${KIE_EXAMPLE:-false}

# Kie Server managed
KIE_SERVER_MANAGED=${KIE_SERVER_MANAGED:-false}

# KIE Controller
KIE_SERVER_CONTROLLER=${KIE_SERVER_CONTROLLER:-false}

# KIE server extensions
RHPAM_EXT_DISABLED=${RHPAM_EXT_DISABLED:-false}
RHDM_EXT_DISABLED=${RHDM_EXT_DISABLED:-false}
BRP_EXT_DISABLED=${BRP_EXT_DISABLED:-false}
JBPMUI_EXT_DISABLED=${JBPMUI_EXT_DISABLED:-false}

# KIE server bypass authenticated user
KIE_SERVER_BYPASS_AUTH_USER=${KIE_SERVER_BYPASS_AUTH_USER:-true}

# KIE Server filter classes
KIE_SERVER_FILTER_CLASSES=${KIE_SERVER_FILTER_CLASSES:-false}

# quartz is enabled by default
QUARTZ=${QUARTZ:-true}

# start rhpam?
if [ "$START_RHPAM" = "false" ] 
then
 echo "START_RHPAM=${START_RHPAM}. Shutting down container."
 sleep 10
 exit 0
fi

# First run?
if [ ! -d "$RHPAM_DATA/configuration" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# start options
RHPAM_OPTS=""

# server opts
SERVER_OPTS=""

# relax restrictions on user passwords
sed -i "s/password.restriction=REJECT/password.restriction=RELAX/" $RHPAM_HOME/$RHPAM_ROOT/bin/add-user.properties

# first run : copy configuration, setup maven, setup datasources, create users
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $RHPAM_DATA/content

  # copy configuration
  echo "Copy configuration to $RHPAM_DATA"
  cp -r $RHPAM_HOME/$RHPAM_ROOT/standalone/configuration $RHPAM_DATA

  # copy standalone-docker.xml
  echo "Copy $JBOSS_CONFIG"
  cp -p --remove-destination $CONTAINER_SCRIPTS_PATH/standalone.xml $RHPAM_DATA/configuration/$JBOSS_CONFIG
  #replace placeholders
  VARS=( RHPAM_DATASOURCE MDB_MAX_POOL )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $RHPAM_DATA/configuration/$JBOSS_CONFIG
  done
  # remove kie login-module for kie-server
  if [ "$KIE_SERVER" = "true" -a ! "$BUSINESS_CENTRAL" = "true" ]; then
    echo "Remove KIE login module"
    sed -i "/^.*org\.kie\.security\.jaas\.KieLoginModule.*$/d" $RHPAM_DATA/configuration/$JBOSS_CONFIG
  fi

  # Setup maven repo
  echo "Setup local maven repo with Nexus"
  cp $CONTAINER_SCRIPTS_PATH/maven-settings.xml $MAVEN_SETTINGS
  VARS=( MAVEN_REPO )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $MAVEN_SETTINGS
  done

  # Remove kie sample project
  echo "Remove org.kie.example"
  if [ ! "$KIE_EXAMPLE" = "true" ];
  then
    sed -i 's/property name="org.kie.example" value="true"/property name="org.kie.example" value="false"/' $RHPAM_DATA/configuration/$JBOSS_CONFIG
  fi


  # Quartz Properties
  echo "Copy quartz properties file"
  cp $CONTAINER_SCRIPTS_PATH/quartz.properties $RHPAM_DATA/configuration/quartz.properties
  #replace placeholders
  VARS=( RHPAM_DATASOURCE QUARTZ_DATASOURCE )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $RHPAM_DATA/configuration/quartz.properties
  done

  # Configure datasources
  if [ "$KIE_SERVER" = "true" ]; then
    echo "Configure $DATABASE datasource"

    # configuration : driver
    DRIVER=$(cat $CONTAINER_SCRIPTS_PATH/$DATABASE-driver-config.xml)
    #replace placeholders in driver file
    VARS=( PGSQL_MODULE_NAME )
    for i in "${VARS[@]}"
    do
      DRIVER=$(echo $DRIVER | sed "s'@@${i}@@'${!i}'")
    done
    sed -i -e ':a' -e '$!{N;ba' -e '}' -e "s/$(quoteRe "<!-- ##DATASOURCE-DRIVERS## -->")/$(quoteSubst "$DRIVER")/" $RHPAM_DATA/configuration/$JBOSS_CONFIG

    # configuration : RHPAM datasource
    RHPAM_DATASOURCE_CONFIG=$(cat $CONTAINER_SCRIPTS_PATH/$DATABASE-rhpam-datasource-config.xml)
    #replace placeholders
    VARS=( RHPAM_DATASOURCE )
    for i in "${VARS[@]}"
    do
      RHPAM_DATASOURCE_CONFIG=$(echo $RHPAM_DATASOURCE_CONFIG | sed "s'@@${i}@@'${!i}'g")
    done

    # configuration : Quartz datasource
    QUARTZ_DATASOURCE_CONFIG=$(cat $CONTAINER_SCRIPTS_PATH/$DATABASE-quartz-datasource-config.xml)
    #replace placeholders
    VARS=( QUARTZ_DATASOURCE )
    for i in "${VARS[@]}"
    do
      QUARTZ_DATASOURCE_CONFIG=$(echo $QUARTZ_DATASOURCE_CONFIG | sed "s'@@${i}@@'${!i}'g")
    done

    if [ "$QUARTZ" = "true" ];
    then
      DATASOURCE=$RHPAM_DATASOURCE_CONFIG$'\n'$QUARTZ_DATASOURCE_CONFIG
    else
      DATASOURCE=$RHPAM_DATASOURCE_CONFIG
    fi
    sed -i -e ':a' -e '$!{N;ba' -e '}' -e "s/$(quoteRe "<!-- ##DATASOURCES## -->")/$(quoteSubst "$DATASOURCE")/" $RHPAM_DATA/configuration/$JBOSS_CONFIG
  fi

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # create application users
  createUser "admin1" "admin" "admin,user,kie-server,kiemgmt,rest-all"
  createUser "busadmin" "busamin" "Administrators,analyst,user,rest-all,kie-server"
  createUser "user1" "user" "user,kie-server"
  createUser "kieserver" "kieserver1!" "kie-server"
  
  # create additional users
  for i in $(compgen -A variable | grep "^RHPAM_USER_");
  do
    IFS=':' read -a bpmsUserArray <<< "${!i}"
    echo "Create user ${bpmsUserArray[0]}"
    createUser ${bpmsUserArray[0]} ${bpmsUserArray[1]} ${bpmsUserArray[2]} 
  done

  # userinfo properties placeholder file
  cp $CONTAINER_SCRIPTS_PATH/jbpm-userinfo.properties $RHPAM_DATA/configuration

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $RHPAM_HOME/$RHPAM_ROOT/standalone/data \
           $RHPAM_HOME/$RHPAM_ROOT/standalone/log \
           $RHPAM_HOME/$RHPAM_ROOT/standalone/tmp
fi

# append standalone.conf to bin/standalone.conf if needed
if ! grep -q "### Dynamic Resources ###" "$RHPAM_HOME/$RHPAM_ROOT/bin/standalone.conf"; then
  cat $CONTAINER_SCRIPTS_PATH/standalone.conf >> $RHPAM_HOME/$RHPAM_ROOT/bin/standalone.conf
fi

# set up postgresql module
PGSQL_MODULE_DIR=$(echo $PGSQL_MODULE_NAME | sed 's@\.@/@g')
PGSQL_MODULE=$RHPAM_HOME/$RHPAM_ROOT/modules/$PGSQL_MODULE_DIR/main
if [ ! -d $PGSQL_MODULE ];
then
  echo "Setup postgresql module"
  mkdir -p $PGSQL_MODULE
  cp -rp $CONTAINER_SCRIPTS_PATH/$DATABASE-module.xml $PGSQL_MODULE/module.xml
  #replace placeholders in module file
  VARS=( PGSQL_MODULE_NAME PGSQL_DRIVER )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $PGSQL_MODULE/module.xml
  done
  ln -s $PGSQL_DRIVER_PATH/$PGSQL_DRIVER $PGSQL_MODULE/$PGSQL_DRIVER
fi

# remove unwanted deployments
if [ ! "$BUSINESS_CENTRAL" = "true" ];
then
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.*
else
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.*
  touch $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.dodeploy
fi

if [ ! "$KIE_SERVER" = "true" ];
then
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.*
else
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.*
  touch $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.dodeploy
fi

# setup nexus in maven settings file
sed -r -i "s'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}'$NEXUS_URL'g" $MAVEN_SETTINGS

# add additional libraries to business-central or kie-server deployment
for i in $(compgen -A variable | grep "^RHPAM_LIB_");
  do
    IFS=':' read -a gav <<< "${!i}"
    gav_lib=${gav[1]}-${gav[2]}.jar
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&e=jar"
    if [ "$KIE_SERVER" = "true" ]; then
      if [ ! -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} ]; then
        echo "Installing library ${gav_lib} in kie-server"
        curl --insecure -s -L -o $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} \
             "$gav_url"
      fi
    fi
  done

# Executor
if [ ! "$EXECUTOR" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.disabled=true"
fi

if [ ! "$EXECUTOR_JMS" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.jms=false"
fi

RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.pool.size=${EXECUTOR_POOL_SIZE}"
RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.retry.count=${EXECUTOR_RETRY_COUNT}"
RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.interval=${EXECUTOR_INTERVAL}"
RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.executor.timeunit=${EXECUTOR_TIMEUNIT}"

# Executor MDB settings
if [ "$KIE_SERVER" = "true" ];
then
  cp -f $CONTAINER_SCRIPTS_PATH/ejb-jar.xml $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war/WEB-INF/
  #replace placeholders
  VARS=( MDB_EXECUTOR_MAX_SESSION )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war/WEB-INF/ejb-jar.xml
  done
fi

# KIE-server in managed mode
if [ "$KIE_SERVER_MANAGED" = "true" ] 
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller=http://${KIE_SERVER_CONTROLLER_IP}:8080/business-central/rest/controller"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller.user=kieserver"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller.pwd=kieserver1!"
fi

# Business Central as KIE controller
if [ "$KIE_SERVER_CONTROLLER" = "true" -a "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.user=kieserver"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.pwd=kieserver1!"
fi

if [ "$KIE_SERVER" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.id=kie-server-$KIE_SERVER_ID"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.location=http://${IPADDR}:8080/kie-server/services/rest/server"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.persistence.ds=java:jboss/datasources/$RHPAM_DATASOURCE"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.persistence.dialect=$DATABASE_DIALECT"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.server.ext.disabled=$RHPAM_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.drools.server.ext.disabled=$RHDM_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.optaplanner.server.ext.disabled=$BRP_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ui.server.ext.disabled=$JBPMUI_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.repo=$RHPAM_DATA/configuration"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.bypass.auth.user=$KIE_SERVER_BYPASS_AUTH_USER"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.drools.server.filter.classes=$KIE_SERVER_FILTER_CLASSES"
fi

if [ "$KIE_SERVER_BYPASS_AUTH_USER" = "true" -a "$KIE_SERVER" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ht.callback=props"
  RHPAM_OPTS="$RHPAM_OPTS -Djbpm.user.group.mapping=file:$RHPAM_DATA/configuration/application-roles.properties"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ht.userinfo=props"
  RHPAM_OPTS="$RHPAM_OPTS -Djbpm.user.info.properties=file:$RHPAM_DATA/configuration/jbpm-userinfo.properties"
elif [ "$KIE_SERVER" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ht.callback=jaas"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ht.userinfo=props"
  RHPAM_OPTS="$RHPAM_OPTS -Djbpm.user.info.properties=file:${RHPAM_DATA}/configuration/jbpm-userinfo.properties"
fi

# business-central
if [ "$BUSINESS_CENTRAL_DESIGN" = "true" -a "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.enabled=true"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=true"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.api.userManagementServices=WildflyCLIUserManagementService"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.port=9990"
elif [ "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.enabled=false"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=false"
fi

if [ "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.dir=$GIT_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.metadata.index.dir=$GIT_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Ddatasource.management.wildfly.host=$IPADDR"
fi

# maven settings
RHPAM_OPTS="$RHPAM_OPTS -Dkie.maven.settings.custom=$MAVEN_SETTINGS"

# setup quartz
if [ "$QUARTZ" = "true" ];
then
  echo "Configure quartz"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.quartz.properties=$RHPAM_DATA/configuration/quartz.properties"
fi

SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.management=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.insecure=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.node.name=server-$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.config.dir=$RHPAM_DATA/configuration"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.deploy.dir=$RHPAM_DATA/content"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.host.ip=$PGSQL_HOST_IP"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.host.port=$PGSQL_HOST_PORT"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.rhpam.schema=$PGSQL_RHPAM_SCHEMA"
SERVER_OPTS="$SERVER_OPTS -Drhpam.datasource.pool.min=$RHPAM_DATASOURCE_POOL_MIN"
SERVER_OPTS="$SERVER_OPTS -Drhpam.datasource.pool.max=$RHPAM_DATASOURCE_POOL_MAX"
SERVER_OPTS="$SERVER_OPTS --server-config=$JBOSS_CONFIG"

# MDB pools
if [ "$KIE_SERVER" = "true" ]
then
  SERVER_OPTS="$SERVER_OPTS -Dactivemq.artemis.client.global.thread.pool.max.size=$MDB_MAX_POOL"
fi

# start-up properties
if [ -n "$STARTUP_PROPS" ]
then
  SERVER_OPTS="$SERVER_OPTS $(eval echo $STARTUP_PROPS)"
fi

# start-up properties
for i in $(compgen -A variable | grep "^STARTUP_PROP_"); do
  prop="${!i}"
  prop_resolved=$(eval echo $prop)
  echo "Adding property ${prop_resolved} to the server startup properties"
  SERVER_OPTS="$SERVER_OPTS ${prop_resolved}"
done

# start-up properties
for i in $(compgen -A variable | grep "^STARTUP_PROP_"); do
  prop="${!i}"
  prop_resolved=$(eval echo $prop)
  echo "Adding property ${prop_resolved} to the server startup properties"
  SERVER_OPTS="$SERVER_OPTS ${prop_resolved}"
done

# Set debug settings
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

dumpEnv

eval "exec $RHPAM_HOME/$RHPAM_ROOT/bin/standalone.sh $RHPAM_OPTS $SERVER_OPTS \"\$@\""
