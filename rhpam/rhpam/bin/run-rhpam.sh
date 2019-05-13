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
  echo $RHPAM_OPTS
  echo SERVER_OPTS
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

PGSQL_HOST_IP=$(ping -q -c 1 -t 1 postgresql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
PGSQL_HOST_PORT=5432

NEXUS_PORT=8080
NEXUS_URL=$NEXUS_HOST:$NEXUS_PORT

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

# Git repo settings
GIT_REPO=$RHPAM_DATA/rhpam-repo

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# Kie Examples
KIE_EXAMPLE=${KIE_EXAMPLE:-false}

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

# KIE admin user
KIE_ADMIN_USER=${KIE_ADMIN_USER:-adminUser}
KIE_ADMIN_PWD=${KIE_ADMIN_PWD:-admin1!}
KIE_ADMIN_ROLES=${KIE_ADMIN_ROLES:-"admin,user,kie-server,kiemgmt,rest-all"}

# KIE Server User
KIE_SERVER_USER=${KIE_SERVER_USER:-executionUser}
KIE_SERVER_PWD=${KIE_SERVER_PWD:-execution1!}
KIE_SERVER_ROLES=${KIE_SERVER_ROLES:-"kie-server,rest-all"}

# Maven settings
MAVEN_LOCAL_REPO=$RHPAM_DATA/m2/repository
MAVEN_SETTINGS=$RHPAM_DATA/configuration/settings.xml
MAVEN_MIRROR_ID=${MAVEN_MIRROR_ID:-nexus}
MAVEN_MIRROR_OF=${MAVEN_MIRROR_OF:-"external:*"}

function configure_maven_repo() {
    local settings=$1
    local repo_url=$2
    local repo_id=$3
    if [[ -z $4 ]]; then
      local prefix="MAVEN"
    else
      local prefix="${4}_MAVEN"
    fi

    if [[ -z ${repo_url} ]]; then
        local repo_service=$(_find_prefixed_env "${prefix}" "REPO_SERVICE")
        # host
        local repo_host=$(_find_prefixed_env "${prefix}" "REPO_HOST")
        if [[ -z ${repo_host} ]]; then
            repo_host=$(_find_prefixed_env "${repo_service}" "SERVICE_HOST")
        fi
        if [[ ! -z ${repo_host} ]]; then
            # protocol
            local repo_protocol=$(_find_prefixed_env "${prefix}" "REPO_PROTOCOL" "http")
            # port
            local repo_port=$(_find_prefixed_env "${prefix}" "REPO_PORT")
            if [ "${repo_port}" = "" ]; then
                repo_port=$(_find_prefixed_env "${repo_service}" "SERVICE_PORT" "8080")
            fi
            local repo_path=$(_find_prefixed_env "${prefix}" "REPO_PATH")
            # strip leading slash if exists
            if [[ "${repo_path}" =~ ^/ ]]; then
                repo_path="${repo_path:1:${#repo_path}}"
            fi
            # url
            repo_url="${repo_protocol}://${repo_host}:${repo_port}/${repo_path}"
        fi
    fi
    if [[ ! -z ${repo_url} ]]; then
        add_maven_repo "${settings}" "${repo_id}" "${repo_url}" "${prefix}_MAVEN"
        add_maven_server "${settings}" "${repo_id}" "${prefix}"
    else
        log_warning "Variable \"${prefix}_REPO_URL\" not set. Skipping maven repo setup for the prefix \"${prefix}\"."
    fi
}

function configure_maven_repos() {
    local settings="${MAVEN_SETTINGS}"
    local local_repo_path="${MAVEN_LOCAL_REPO}"
    if [ "${local_repo_path}" != "" ]; then
        set_local_repo_path "${settings}" "${local_repo_path}"
    fi

    local single_repo_url="${MAVEN_REPO_URL}"
    if [ -n "$single_repo_url" ]; then
      local single_repo_id=$(_find_env "MAVEN_REPO_ID" "repo-$(generate_random_id)")
      configure_maven_repo $settings "$single_repo_url" "$single_repo_id"
    fi

    local multi_repo_counter=1
    IFS=',' read -a multi_repo_prefixes <<< ${MAVEN_REPOS}
    for multi_repo_prefix in ${multi_repo_prefixes[@]}; do
        local multi_repo_url=$(_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_URL")
        local multi_repo_id=$(_find_prefixed_env "${multi_repo_prefix}" "MAVEN_REPO_ID" "repo${multi_repo_counter}-$(generate_random_id)")
        configure_maven_repo $settings "$multi_repo_url" "$multi_repo_id" $multi_repo_prefix
        multi_repo_counter=$((multi_repo_counter+1))
    done
}

function add_maven_repo() {

  local settings=$1
  local repo_id=$2
  local url=$3
  local prefix=$4

  local layout=$(_find_prefixed_env "${prefix}" "REPO_LAYOUT" "default")
  local releases_enabled=$(_find_prefixed_env "${prefix}" "REPO_RELEASES_ENABLED" true)
  local releases_update_policy=$(_find_prefixed_env "${prefix}" "REPO_RELEASES_UPDATE_POLICY" "always")
  local snapshots_enabled=$(_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_ENABLED" true)
  local snapshots_update_policy=$(_find_prefixed_env "${prefix}" "REPO_SNAPSHOTS_UPDATE_POLICY" "always")

  # configure the repository in a profile
  local profile_id="${repo_id}-profile"
  local xml="\n\
  <profile>\n\
    <id>${profile_id}</id>\n\
    <repositories>\n\
      <repository>\n\
        <id>${repo_id}</id>\n\
        <url>${url}</url>\n\
        <layout>${layout}</layout>\n\
        <releases>\n\
          <enabled>${releases_enabled}</enabled>\n\
          <updatePolicy>${releases_update_policy}</updatePolicy>\n\
        </releases>\n\
        <snapshots>\n\
          <enabled>${snapshots_enabled}</enabled>\n\
          <updatePolicy>${snapshots_update_policy}</updatePolicy>\n\
        </snapshots>\n\
      </repository>\n\
    </repositories>\n\
  </profile>\n\
  <!-- ### configured profiles ### -->"
  sed -i "s|<!-- ### configured profiles ### -->|${xml}|" "${settings}"

  # activate the configured profile
  xml="\n\
  <activeProfile>${profile_id}</activeProfile>\n\
  <!-- ### active profiles ### -->"
  sed -i "s|<!-- ### active profiles ### -->|${xml}|" "${settings}"
}

function add_maven_server() {
    local settings=$1
    local server_id=$2
    local prefix=$3

    local username=$(_find_prefixed_env "$prefix" REPO_USERNAME)
    local password=$(_find_prefixed_env "$prefix" "REPO_PASSWORD")
    local private_key=$(_find_prefixed_env "$prefix" "REPO_PRIVATE_KEY")
    local passphrase=$(_find_prefixed_env "$prefix" "REPO_PASSPHRASE")

    local do_rewrite="false"
    local xml="\n\
    <server>\n\
      <id>${server_id}</id>"
    if [ "${private_key}" != "" -a "${passphrase}" != "" ]; then
        xml="${xml}\n\
      <privateKey>${private_key}</privateKey>\n\
      <passphrase><![CDATA[${passphrase}]]></passphrase>"
        do_rewrite="true"
    fi
    if [ "${username}" != "" -a "${password}" != "" ]; then
        xml="${xml}\n\
      <username>${username}</username>\n\
      <password><![CDATA[${password}]]></password>"
        do_rewrite="true"
    fi
    xml="${xml}\n\
    </server>\n\
    <!-- ### configured servers ### -->"
    sed -i "s|<!-- ### configured servers ### -->|${xml}|" "${settings}"

}

function configure_mirror() {
  local settings="${1}"
  local mirror_id="${2}"
  local mirror_url="${3}"
  local mirror_of="${4}"

  local xml="<mirror>\n\
      <id>${mirror_id}</id>\n\
      <url>${mirror_url}</url>\n\
      <mirrorOf>${mirror_of}</mirrorOf>\n\
    </mirror>\n\
    <!-- ### configured mirrors ### -->"

  sed -i "s|<!-- ### configured mirrors ### -->|$xml|" "${settings}"
}

function _find_prefixed_env() {
  local prefix=$1

  if [[ -z $prefix ]]; then
    _find_env $2 $3
  else
    prefix=${prefix^^} # uppercase
    prefix=${prefix//-/_} #replace - by _

    local var_name=$prefix"_"$2
    echo ${!var_name:-$3}
  fi
}

function _find_env() {
  var=${!1}
  echo "${var:-$2}"
}

function generate_random_id() {
    cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1
}

function set_local_repo_path() {
    local settings="${1}"
    local local_path="${2}"
    local xml="\n\
    <localRepository>${local_path}</localRepository>"
    sed -i "s|<!-- ### configured local repository ### -->|${xml}|" "${settings}"
}

# KIE Controller
if [ -n "$KIE_SERVER_CONTROLLER_HOST" -a "$KIE_SERVER_CONTROLLER_HOST" = "local" ]; then
  KIE_SERVER_CONTROLLER_IP=$IPADDR
elif [ -n "$KIE_SERVER_CONTROLLER_HOST" ]; then
  KIE_SERVER_CONTROLLER_IP=${KIE_SERVER_CONTROLLER_HOST}
fi
# http or ws
KIE_SERVER_CONTROLLER_PROTOCOL=${KIE_SERVER_CONTROLLER_PROTOCOL:-ws}
KIE_SERVER_CONTROLLER_PORT=${KIE_SERVER_CONTROLLER_PORT:-8080}

KIE_SERVER_CONTROLLER=${KIE_SERVER_CONTROLLER:-false}
KIE_SERVER_CONTROLLER_USER=${KIE_SERVER_CONTROLLER_USER:-controllerUser}
KIE_SERVER_CONTROLLER_PWD=${KIE_SERVER_CONTROLLER_PWD:-controller1!}
KIE_SERVER_CONTROLLER_ROLES=${KIE_SERVER_CONTROLLER_ROLES:-"kie-server,rest-all,guest"}

function configure_controller_access {
  # host
  local kieServerControllerHost="${KIE_SERVER_CONTROLLER_IP}"
  # port
  local kieServerControllerPort="${KIE_SERVER_CONTROLLER_PORT}"
  # protocol
  local kieServerControllerProtocol=${KIE_SERVER_CONTROLLER_PROTOCOL}
  # path
  local kieServerControllerPath
  if [ "$KIE_SERVER_CONTROLLER_TYPE" = "bc" ]; then
    kieServerControllerPath="business-central"
  else
    kieServerControllerPath="controller"
  fi  
  if [ "${kieServerControllerProtocol}" = "ws" ]; then
    kieServerControllerPath=${kieServerControllerPath}/websocket/controller
  else
    kieServerControllerPath=${kieServerControllerPath}/rest/controller
  fi
  # url
  local kieServerControllerUrl="${kieServerControllerProtocol}://${kieServerControllerHost}:${kieServerControllerPort}/${kieServerControllerPath}"
  
  # KIE-server in managed mode
  if [ "$KIE_SERVER_MANAGED" = "true" ] 
  then
    RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller=${kieServerControllerUrl}"
    RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller.user=${KIE_SERVER_CONTROLLER_USER}"
    RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.controller.pwd=${KIE_SERVER_CONTROLLER_PWD}"
  fi
}

# KIE Server sync deploy
KIE_SERVER_SYNC_DEPLOY=${KIE_SERVER_SYNC_DEPLOY:=true}

# KIE server extensions
RHPAM_EXT_DISABLED=${RHPAM_EXT_DISABLED:-false}
RHDM_EXT_DISABLED=${RHDM_EXT_DISABLED:-false}
BRP_EXT_DISABLED=${BRP_EXT_DISABLED:-false}
JBPMUI_EXT_DISABLED=${JBPMUI_EXT_DISABLED:-false}
RHPAM_CASE_EXT_DISABLED=${RHPAM_CASE_EXT_DISABLED:-false}

# KIE server bypass authenticated user
KIE_SERVER_BYPASS_AUTH_USER=${KIE_SERVER_BYPASS_AUTH_USER:-true}

# KIE Server filter classes
KIE_SERVER_FILTER_CLASSES=${KIE_SERVER_FILTER_CLASSES:-false}

# KIE Server Document storage
DOC_STORAGE=${DOC_STORAGE:-$RHPAM_DATA/docs}

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
  
  # remove kie login-module for kie-server and headless controller
  if [ ! "$BUSINESS_CENTRAL" = "true" ]; then
    echo "Remove KIE login module"
    sed -i "/^.*org\.kie\.security\.jaas\.KieLoginModule.*$/d" $RHPAM_DATA/configuration/$JBOSS_CONFIG
  fi

  # Setup maven
  echo "Setup maven"
  cp $CONTAINER_SCRIPTS_PATH/maven-settings.xml $MAVEN_SETTINGS
  configure_maven_repos

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
  createUser $KIE_ADMIN_USER $KIE_ADMIN_PWD $KIE_ADMIN_ROLES
  createUser "busadmin" "busadmin" "Administrators,analyst,user,rest-all,kie-server"
  createUser "user1" "user" "user,kie-server"
  createUser $KIE_SERVER_USER $KIE_SERVER_PWD $KIE_SERVER_ROLES
  createUser $KIE_SERVER_CONTROLLER_USER $KIE_SERVER_CONTROLLER_PWD $KIE_SERVER_CONTROLLER_ROLES 
  
  # create additional users
  for i in $(compgen -A variable | grep "^RHPAM_USER_");
  do
    IFS=':' read -a rhpamUserArray <<< "${!i}"
    echo "Create user ${rhpamUserArray[0]}"
    createUser ${rhpamUserArray[0]} ${rhpamUserArray[1]} ${rhpamUserArray[2]} 
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
if [ "$BUSINESS_CENTRAL" = "true" ];
then
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.*
  touch $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.dodeploy
else
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/business-central.war.*
fi

if [ "$KIE_SERVER" = "true" ];
then
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.*
  touch $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.dodeploy
else
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/kie-server.war.*
fi

if [ "$KIE_SERVER_CONTROLLER" = "true" -a ! "$BUSINESS_CENTRAL" = "true" ];
then
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/controller.war.*
  touch $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/controller.war.dodeploy
else
  rm -f $RHPAM_HOME/$RHPAM_ROOT/standalone/deployments/controller.war.*
fi

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
  configure_controller_access
fi

# Business Central as KIE controller
if [ "$KIE_SERVER_CONTROLLER" = "true" -a ! "$KIE_SERVER" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.user=${KIE_SERVER_USER}"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.pwd=${KIE_SERVER_PWD}"
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
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.case.server.ext.disabled=$RHPAM_CASE_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.ui.server.ext.disabled=$JBPMUI_EXT_DISABLED"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.repo=$RHPAM_DATA/configuration"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.bypass.auth.user=$KIE_SERVER_BYPASS_AUTH_USER"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.drools.server.filter.classes=$KIE_SERVER_FILTER_CLASSES"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.server.sync.deploy=$KIE_SERVER_SYNC_DEPLOY"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.document.storage=$DOC_STORAGE"
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
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.algorithm=RSA"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=true"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.api.userManagementServices=WildflyCLIUserManagementService"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.port=9990"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.appformer.m2repo.url=http://$IPADDR:8080/business-central/maven2"
elif [ "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.enabled=false"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=false"
fi

if [ "$BUSINESS_CENTRAL" = "true" ]
then
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.jbpm.designer.perspective=full -Ddesignerdataobjects=false"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_LOCAL_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.dir=$GIT_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.nio.git.ssh.cert.dir=$GIT_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.uberfire.metadata.index.dir=$GIT_REPO"
  RHPAM_OPTS="$RHPAM_OPTS -Ddatasource.management.wildfly.host=$IPADDR"
  RHPAM_OPTS="$RHPAM_OPTS -Dorg.kie.demo=$KIE_EXAMPLE -Dorg.kie.example=$KIE_EXAMPLE"
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
