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
    $BPMS_HOME/$BPMS_ROOT/bin/add-user.sh -u $user -p $password -s -sc $BPMS_DATA/configuration
  else
    $BPMS_HOME/$BPMS_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $BPMS_DATA/configuration
  fi
}

# Build Classpath for dynamic creation of server state file
function getKieClassPath() {
    kieJarDir="${BPMS_HOME}/${BPMS_ROOT}/standalone/deployments/kie-server.war/WEB-INF/lib"
    kieClassPath="."
    for kieJar in `ls ${kieJarDir}/*.jar` ; do
        kieClassPath="${kieClassPath}:${kieJar}"
    done
    modJarDir="${BPMS_HOME}/${BPMS_ROOT}/modules/system/layers/base"
    modJarPaths="javax/enterprise/api javax/inject/api"
    for modJarPath in ${modJarPaths} ; do
        for modJar in `ls ${modJarDir}/${modJarPath}/main/*.jar` ; do
            kieClassPath="${kieClassPath}:${modJar}"
        done
    done
    echo "${kieClassPath}"
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
  echo "DASHBOARD: ${DASHBOARD}"
  echo "PGSQL_BPMS_SCHEMA: ${PGSQL_BPMS_SCHEMA}"
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
  echo "BPMS_DATASOURCE_POOL_MIN: ${BPMS_DATASOURCE_POOL_MIN}"
  echo "BPMS_DATASOURCE_POOL_MAX: ${BPMS_DATASOURCE_POOL_MAX}"
  if [ "${KIE_SERVER}" = "true" ];then
    echo "KIE_SERVER_ID: ${KIE_SERVER_ID}"
    echo "KIE_SERVER_MANAGED: ${KIE_SERVER_MANAGED}"
    echo "BPMS_EXT_DISABLED: ${BPMS_EXT_DISABLED}"
    echo "BRMS_EXT_DISABLED: ${BRMS_EXT_DISABLED}"
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
if [ -n "$KIE_SERVER_CONTROLLER_HOST" ];
then
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
PGSQL_MODULE_NAME=com.postgresql
BPMS_DATASOURCE_POOL_MIN=${BPMS_DATASOURCE_POOL_MIN:-0}
BPMS_DATASOURCE_POOL_MAX=${BPMS_DATASOURCE_POOL_MAX:-20}
BPMS_DATASOURCE=jbpmDS
QUARTZ_DATASOURCE=quartzDS

# Standalone config file
JBOSS_CONFIG=standalone-docker.xml

# Maven settings
MAVEN_REPO=$BPMS_DATA/m2/repository
MAVEN_SETTINGS=$BPMS_DATA/configuration/settings.xml

# Git repo settings
GIT_REPO=$BPMS_DATA/bpms-repo

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

# Kie Server managed
KIE_SERVER_MANAGED=${KIE_SERVER_MANAGED:-false}

# KIE Controller
KIE_SERVER_CONTROLLER=${KIE_SERVER_CONTROLLER:-false}

# KIE server extensions
BPMS_EXT_DISABLED=${BPMS_EXT_DISABLED:-false}
BRMS_EXT_DISABLED=${BRMS_EXT_DISABLED:-false}
BRP_EXT_DISABLED=${BRP_EXT_DISABLED:-false}
JBPMUI_EXT_DISABLED=${JBPMUI_EXT_DISABLED:-false}

# KIE server bypass authenticated user
KIE_SERVER_BYPASS_AUTH_USER=${KIE_SERVER_BYPASS_AUTH_USER:-true}

# KIE Server filter classes
KIE_SERVER_FILTER_CLASSES=${KIE_SERVER_FILTER_CLASSES:-false}

# quartz is enabled by default
QUARTZ=${QUARTZ:-true}

# start bpms?
if [ "$START_BPMS" = "false" ] 
then
 echo "START_BPMS=${START_BPMS}. Shutting down container."
 sleep 10
 exit 0
fi

# First run?
if [ ! -d "$BPMS_DATA/configuration" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# start options
BPMS_OPTS=""

# server opts
SERVER_OPTS=""

# relax restrictions on user passwords
sed -i "s/password.restriction=REJECT/password.restriction=RELAX/" $BPMS_HOME/$BPMS_ROOT/bin/add-user.properties

# first run : copy configuration, setup maven, setup datasources, create users
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $BPMS_DATA/content

  # copy configuration
  echo "Copy configuration to $BPMS_DATA"
  cp -r $BPMS_HOME/$BPMS_ROOT/standalone/configuration $BPMS_DATA

  # copy standalone-docker.xml
  echo "Copy $JBOSS_CONFIG"
  cp -p --remove-destination $CONTAINER_SCRIPTS_PATH/standalone.xml $BPMS_DATA/configuration/$JBOSS_CONFIG
  #replace placeholders
  VARS=( BPMS_DATASOURCE MDB_MAX_POOL )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $BPMS_DATA/configuration/$JBOSS_CONFIG
  done  

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
  sed -i 's/property name="org.kie.example" value="true"/property name="org.kie.example" value="false"/' $BPMS_DATA/configuration/$JBOSS_CONFIG

  # Quartz Properties
  echo "Copy quartz properties file"
  cp $CONTAINER_SCRIPTS_PATH/quartz.properties $BPMS_DATA/configuration/quartz.properties
  #replace placeholders
  VARS=( BPMS_DATASOURCE QUARTZ_DATASOURCE )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $BPMS_DATA/configuration/quartz.properties
  done

  # Configure datasources
  echo "Configure $DATABASE datasource"

  # configuration : driver
  DRIVER=$(cat $CONTAINER_SCRIPTS_PATH/$DATABASE-driver-config.xml)
  #replace placeholders in driver file
  VARS=( PGSQL_MODULE_NAME )
  for i in "${VARS[@]}"
  do
    DRIVER=$(echo $DRIVER | sed "s'@@${i}@@'${!i}'")
  done
  sed -i -e ':a' -e '$!{N;ba' -e '}' -e "s/$(quoteRe "<!-- ##DATASOURCE-DRIVERS## -->")/$(quoteSubst "$DRIVER")/" $BPMS_DATA/configuration/$JBOSS_CONFIG

  # configuration : BPMS datasource
  BPMS_DATASOURCE_CONFIG=$(cat $CONTAINER_SCRIPTS_PATH/$DATABASE-bpms-datasource-config.xml)
  #replace placeholders
  VARS=( BPMS_DATASOURCE )
  for i in "${VARS[@]}"
  do
    BPMS_DATASOURCE_CONFIG=$(echo $BPMS_DATASOURCE_CONFIG | sed "s'@@${i}@@'${!i}'g")
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
    DATASOURCE=$BPMS_DATASOURCE_CONFIG$'\n'$QUARTZ_DATASOURCE_CONFIG
  else
    DATASOURCE=$BPMS_DATASOURCE_CONFIG
  fi
  sed -i -e ':a' -e '$!{N;ba' -e '}' -e "s/$(quoteRe "<!-- ##DATASOURCES## -->")/$(quoteSubst "$DATASOURCE")/" $BPMS_DATA/configuration/$JBOSS_CONFIG

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # create application users
  createUser "admin1" "admin" "admin,analyst,user,kie-server,kiemgmt,rest-all"
  createUser "busadmin" "busamin" "Administrators,analyst,user,rest-all"
  createUser "user1" "user" "user,reviewer,kie-server,rest-task,rest-query,rest-process"
  createUser "kieserver" "kieserver1!" "kie-server,rest-all"
  
  # create additional users
  for i in $(compgen -A variable | grep "^BPMS_USER_");
  do
    IFS=':' read -a bpmsUserArray <<< "${!i}"
    echo "Create user ${bpmsUserArray[0]}"
    createUser ${bpmsUserArray[0]} ${bpmsUserArray[1]} ${bpmsUserArray[2]} 
  done

  # userinfo properties placeholder file
  cp $CONTAINER_SCRIPTS_PATH/jbpm-userinfo.properties $BPMS_DATA/configuration

  # generate server state  
  CONTAINERS=""
  for i in $(compgen -A variable | grep "^KIESERVER_CONTAINER_"); do
    CONTAINERS="${CONTAINERS}|${!i}"
  done
  
  if [ "$KIE_SERVER" = "true" -a -n "$CONTAINERS" ]; then
    echo "Generate KIE-server state xml"
    CONTAINERS=${CONTAINERS#"|"}
    echo "Containers to be deployed: $CONTAINERS"
    serverconfig_lib_groupId=org.jboss.btison.bpms.kieserver
    serverconfig_lib_artifactId=kieserver-serverconfig
    serverconfig_lib_version=1.0.0
    serverconfig_lib=${serverconfig_lib_artifactId}-${serverconfig_lib_version}.jar
    serverconfig_lib_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${serverconfig_lib_groupId}&a=${serverconfig_lib_artifactId}&v=${serverconfig_lib_version}&e=jar"
    curl --insecure -s -L -o $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${serverconfig_lib} \
             "${serverconfig_lib_url}"
    java -cp $(getKieClassPath) org.jboss.btison.bpms.kieserver.ServerConfig \
      --serverRepo ${BPMS_DATA}/configuration --serverId kie-server-${KIE_SERVER_ID} \
      --containers ${CONTAINERS} \
      > ${BPMS_DATA}/configuration/kie-server-${KIE_SERVER_ID}.xml
  fi

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $BPMS_HOME/$BPMS_ROOT/standalone/data \
           $BPMS_HOME/$BPMS_ROOT/standalone/log \
           $BPMS_HOME/$BPMS_ROOT/standalone/tmp
fi

# append standalone.conf to bin/standalone.conf if needed
if ! grep -q "### Dynamic Resources ###" "$BPMS_HOME/$BPMS_ROOT/bin/standalone.conf"; then
  cat $CONTAINER_SCRIPTS_PATH/standalone.conf >> $BPMS_HOME/$BPMS_ROOT/bin/standalone.conf
fi

# set up postgresql module
PGSQL_MODULE_DIR=$(echo $PGSQL_MODULE_NAME | sed 's@\.@/@g')
PGSQL_MODULE=$BPMS_HOME/$BPMS_ROOT/modules/$PGSQL_MODULE_DIR/main
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

# Configure business-central persistence.xml
echo "Configure business-central persistence.xml"
sed -i s/java:jboss\\/datasources\\/ExampleDS/java:jboss\\/datasources\\/${BPMS_DATASOURCE}/ $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml
sed -i s/org.hibernate.dialect.H2Dialect/${DATABASE_DIALECT}/ $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml

# Configure persistence in dashboard app
echo "Configure persistence Dashboard app"
sed -i s/java:jboss\\/datasources\\/ExampleDS/java:jboss\\/datasources\\/${BPMS_DATASOURCE}/ $BPMS_HOME/$BPMS_ROOT/standalone/deployments/dashbuilder.war/WEB-INF/jboss-web.xml

# remove unwanted deployments
if [ ! "$BUSINESS_CENTRAL" = "true" ];
then
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war.*
else
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war.*
  touch $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war.dodeploy
fi

if [ ! "$KIE_SERVER" = "true" ];
then
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war.*
else
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war.*
  touch $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war.dodeploy
fi

if [ ! "$DASHBOARD" = "true" ];
then
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/dashbuilder.war.*
else
  rm -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/dashbuilder.war.*
  touch $BPMS_HOME/$BPMS_ROOT/standalone/deployments/dashbuilder.war.dodeploy
fi

# setup nexus in maven settings file
sed -r -i "s'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}'$NEXUS_URL'g" $MAVEN_SETTINGS

# add additional libraries to business-central or kie-server deployment
for i in $(compgen -A variable | grep "^BPMS_LIB_");
  do
    IFS=':' read -a gav <<< "${!i}"
    gav_lib=${gav[1]}-${gav[2]}.jar
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&e=jar"
    if [ "$KIE_SERVER" = "true" ]; then
      if [ ! -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} ]; then
        echo "Installing library ${gav_lib} in kie-server"
        curl --insecure -s -L -o $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} \
             "$gav_url"
      fi
    fi
    if [ "$BUSINESS_CENTRAL" = "true" ]; then
      if [ ! -f $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war/WEB-INF/lib/${gav_lib} ]; then
        echo "Installing library ${gav_lib} in business-central"
        curl --insecure -s -L -o $BPMS_HOME/$BPMS_ROOT/standalone/deployments/business-central.war/WEB-INF/lib/${gav_lib} \
             "$gav_url"
      fi
    fi
  done

# Executor
if [ ! "$EXECUTOR" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.disabled=true"
fi

if [ ! "$EXECUTOR_JMS" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.jms=false"
fi

BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.pool.size=${EXECUTOR_POOL_SIZE}"
BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.retry.count=${EXECUTOR_RETRY_COUNT}"
BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.interval=${EXECUTOR_INTERVAL}"
BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.timeunit=${EXECUTOR_TIMEUNIT}"

# Executor MDB settings
if [ "$KIE_SERVER" = "true" ];
then
  cp -f $CONTAINER_SCRIPTS_PATH/ejb-jar.xml $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/
  #replace placeholders
  VARS=( MDB_EXECUTOR_MAX_SESSION )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'g" $BPMS_HOME/$BPMS_ROOT/standalone/deployments/kie-server.war/WEB-INF/ejb-jar.xml
  done
fi

# KIE-server in managed mode
if [ "$KIE_SERVER_MANAGED" = "true" ] 
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller=http://${KIE_SERVER_CONTROLLER_IP}:8080/business-central/rest/controller"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller.user=kieserver"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller.pwd=kieserver1!"
fi

# Business Central as KIE controller
if [ "$KIE_SERVER_CONTROLLER" = "true" -a "$BUSINESS_CENTRAL" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.user=admin1"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.pwd=admin"
fi

if [ "$KIE_SERVER" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.id=kie-server-$KIE_SERVER_ID"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.location=http://${IPADDR}:8080/kie-server/services/rest/server"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.persistence.ds=java:jboss/datasources/$BPMS_DATASOURCE"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.persistence.dialect=$DATABASE_DIALECT"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.server.ext.disabled=$BPMS_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.drools.server.ext.disabled=$BRMS_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.optaplanner.server.ext.disabled=$BRP_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ui.server.ext.disabled=$JBPMUI_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.repo=$BPMS_DATA/configuration"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.bypass.auth.user=$KIE_SERVER_BYPASS_AUTH_USER"
  BPMS_OPTS="$BPMS_OPTS -Dorg.drools.server.filter.classes=$KIE_SERVER_FILTER_CLASSES"
fi

if [ "$KIE_SERVER_BYPASS_AUTH_USER" = "true" -a "$KIE_SERVER" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.callback=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.group.mapping=file:$BPMS_DATA/configuration/application-roles.properties"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.userinfo=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.info.properties=file:$BPMS_DATA/configuration/jbpm-userinfo.properties"
elif [ "$KIE_SERVER" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.callback=jaas"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.userinfo=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.info.properties=file:${BPMS_DATA}/configuration/jbpm-userinfo.properties"
fi

# business-central
if [ "$BUSINESS_CENTRAL_DESIGN" = "true" -a "$BUSINESS_CENTRAL" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.enabled=true"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.enabled=true"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.api.userManagementServices=WildflyCLIUserManagementService"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.port=9990"
elif [ "$BUSINESS_CENTRAL" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.enabled=false"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.enabled=false"
fi

if [ "$BUSINESS_CENTRAL" = "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_REPO"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.dir=$GIT_REPO"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.metadata.index.dir=$GIT_REPO"
fi

# maven settings
BPMS_OPTS="$BPMS_OPTS -Dkie.maven.settings.custom=$MAVEN_SETTINGS"

# setup quartz
if [ "$QUARTZ" = "true" ];
then
  echo "Configure quartz"
  BPMS_OPTS="$BPMS_OPTS -Dorg.quartz.properties=$BPMS_DATA/configuration/quartz.properties"
fi

SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.management=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.insecure=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.node.name=server-$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.config.dir=$BPMS_DATA/configuration"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.deploy.dir=$BPMS_DATA/content"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.host.ip=$PGSQL_HOST_IP"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.host.port=$PGSQL_HOST_PORT"
SERVER_OPTS="$SERVER_OPTS -Dpgsql.bpms.schema=$PGSQL_BPMS_SCHEMA"
SERVER_OPTS="$SERVER_OPTS -Dbpms.datasource.pool.min=$BPMS_DATASOURCE_POOL_MIN"
SERVER_OPTS="$SERVER_OPTS -Dbpms.datasource.pool.max=$BPMS_DATASOURCE_POOL_MAX"
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

# Set debug settings
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug mode = true"
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

dumpEnv

eval "exec $BPMS_HOME/$BPMS_ROOT/bin/standalone.sh $BPMS_OPTS $SERVER_OPTS \"\$@\""
