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
    $RHDM_HOME/$RHDM_ROOT/bin/add-user.sh -u $user -p $password -s -sc $RHDM_DATA/configuration
  else
    $RHDM_HOME/$RHDM_ROOT/bin/add-user.sh -u $user -p $password -g $roles -a -s -sc $RHDM_DATA/configuration
  fi
}

# Dump environment
function dumpEnv() {
  echo "FIRST_RUN: ${FIRST_RUN}"
  echo $RHDM_OPTS
  echo $SERVER_OPTS
}

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

NEXUS_PORT=8080
NEXUS_URL=$NEXUS_HOST:$NEXUS_PORT

FIRST_RUN=false
CLEAN=${CLEAN:-false}

# Standalone config file
JBOSS_CONFIG=standalone-docker.xml

# Git repo settings
GIT_REPO=$RHDM_DATA/rhdm-repo

# debug options
DEBUG_MODE=${DEBUG_MODE:-false}
DEBUG_PORT=${DEBUG_PORT:-8787}

# Kie Examples
KIE_EXAMPLE=${KIE_EXAMPLE:-false}

# Kie Server managed
KIE_SERVER_MANAGED=${KIE_SERVER_MANAGED:-false}

# KIE admin user
KIE_ADMIN_USER=${KIE_ADMIN_USER:-admin1}
KIE_ADMIN_PWD=${KIE_ADMIN_PWD:-admin}
KIE_ADMIN_ROLES=${KIE_ADMIN_ROLES:-"admin,user,kie-server,kiemgmt,rest-all"}

# KIE Server User
KIE_SERVER_USER=${KIE_SERVER_USER:-kieserver}
KIE_SERVER_PWD=${KIE_SERVER_PWD:-kieserver1!}
KIE_SERVER_ROLES=${KIE_SERVER_ROLES:-"kie-server,rest-all"}

# Maven settings
MAVEN_REPO=$RHDM_DATA/m2/repository
MAVEN_SETTINGS=$RHDM_DATA/configuration/settings.xml
MAVEN_REPO_LAYOUT=${MAVEN_REPO_LAYOUT:-default}
MAVEN_REPO_RELEASES_ENABLED=${MAVEN_REPO_RELEASES_ENABLED:-true}
MAVEN_REPO_RELEASES_UPDATE_POLICY=${MAVEN_REPO_RELEASES_UPDATE_POLICY:-always}
MAVEN_REPO_SNAPSHOTS_ENABLED=${MAVEN_REPO_SNAPSHOTS_ENABLED:-true}
MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY=${MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY:-always}
MAVEN_REPO_USER_NAME=${MAVEN_REPO_USER_NAME:-$KIE_ADMIN_USER}
MAVEN_REPO_PASSWORD=${MAVEN_REPO_PASSWORD:-$KIE_ADMIN_PWD}
MAVEN_REPO_PROTOCOL=${MAVEN_REPO_PROTOCOL:-http}
MAVEN_REPO_PORT=${MAVEN_REPO_PORT:-8080}
MAVEN_REPO_PATH=${MAVEN_REPO_PATH:-"decision-central/maven2/"}
MAVEN_MIRROR_ID=${MAVEN_MIRROR_ID:-nexus}
MAVEN_MIRROR_OF=${MAVEN_MIRROR_OF:-"external:*"}

function add_maven_repo() {

  local settings=$1
  local repo_id=$2
  local url=$3

  local layout=${MAVEN_REPO_LAYOUT}
  local releases_enabled=${MAVEN_REPO_RELEASES_ENABLED}
  local releases_update_policy=${MAVEN_REPO_RELEASES_UPDATE_POLICY}
  local snapshots_enabled=${MAVEN_REPO_SNAPSHOTS_ENABLED}
  local snapshots_update_policy=${MAVEN_REPO_SNAPSHOTS_UPDATE_POLICY}

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

    local username=$MAVEN_REPO_USER_NAME
    local password=$MAVEN_REPO_PASSWORD

    local do_rewrite="false"
    local xml="\n\
    <server>\n\
      <id>${server_id}</id>"
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
  local kieServerControllerPath="decision-central/rest/controller"
  if [ "${kieServerControllerProtocol}" = "ws" ]; then
    kieServerControllerPath="decision-central/websocket/controller"
  fi
  # url
  local kieServerControllerUrl="${kieServerControllerProtocol}://${kieServerControllerHost}:${kieServerControllerPort}/${kieServerControllerPath}"
  
  # KIE-server in managed mode
  if [ "$KIE_SERVER_MANAGED" = "true" ] 
  then
    RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.controller=${kieServerControllerUrl}"
    RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.controller.user=${KIE_SERVER_CONTROLLER_USER}"
    RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.controller.pwd=${KIE_SERVER_CONTROLLER_PWD}"
  fi
}

# KIE Server sync deploy
KIE_SERVER_SYNC_DEPLOY=${KIE_SERVER_SYNC_DEPLOY:=true}

# KIE server extensions
RHDM_EXT_DISABLED=${RHDM_EXT_DISABLED:-false}
BRP_EXT_DISABLED=${BRP_EXT_DISABLED:-false}

# KIE Server filter classes
KIE_SERVER_FILTER_CLASSES=${KIE_SERVER_FILTER_CLASSES:-false}

# start rhdm?
if [ "$START_RHDM" = "false" ] 
then
 echo "START_RHDM=${START_RHDM}. Shutting down container."
 sleep 10
 exit 0
fi

# First run?
if [ ! -d "$RHDM_DATA/configuration" ]; then 
  FIRST_RUN=true
  echo "First run"
fi

# start options
RHDM_OPTS=""

# server opts
SERVER_OPTS=""

# relax restrictions on user passwords
sed -i "s/password.restriction=REJECT/password.restriction=RELAX/" $RHDM_HOME/$RHDM_ROOT/bin/add-user.properties

# first run : copy configuration, setup maven, setup datasources, create users
if [ "$FIRST_RUN" = "true" ]; then
  mkdir -p $RHDM_DATA/content

  # copy configuration
  echo "Copy configuration to $RHDM_DATA"
  cp -r $RHDM_HOME/$RHDM_ROOT/standalone/configuration $RHDM_DATA

  # copy standalone-docker.xml
  echo "Copy $JBOSS_CONFIG"
  cp -p --remove-destination $CONTAINER_SCRIPTS_PATH/standalone.xml $RHDM_DATA/configuration/$JBOSS_CONFIG

  # Setup maven repo
  echo "Setup local maven repo with Nexus"
  cp $CONTAINER_SCRIPTS_PATH/maven-settings.xml $MAVEN_SETTINGS
  VARS=( MAVEN_REPO )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $MAVEN_SETTINGS
  done

  if [[ ! -z ${MAVEN_REPO_HOST} ]];
  then
    repo_url="${MAVEN_REPO_PROTOCOL}://${MAVEN_REPO_HOST}:${MAVEN_REPO_PORT}/${MAVEN_REPO_PATH}"
    add_maven_repo "${MAVEN_SETTINGS}" "${MAVEN_REPO_HOST}" "${repo_url}"
    add_maven_server "${MAVEN_SETTINGS}" "${MAVEN_REPO_HOST}"
  fi

  if [ -n "${MAVEN_MIRROR_URL}" ];
  then
    configure_mirror "${MAVEN_SETTINGS}" "${MAVEN_MIRROR_ID}" "${MAVEN_MIRROR_URL}" "${MAVEN_MIRROR_OF}"
  fi

  echo "Create users"
  # create admin user
  createUser "admin" "admin"

  # create application users
  createUser $KIE_ADMIN_USER $KIE_ADMIN_PWD $KIE_ADMIN_ROLES
  createUser "user1" "user" "user,kie-server"
  createUser $KIE_SERVER_USER $KIE_SERVER_PWD $KIE_SERVER_ROLES
  createUser $KIE_SERVER_CONTROLLER_USER $KIE_SERVER_CONTROLLER_PWD $KIE_SERVER_CONTROLLER_ROLES 
  
  # create additional users
  for i in $(compgen -A variable | grep "^RHDM_USER_");
  do
    IFS=':' read -a rhdmUserArray <<< "${!i}"
    echo "Create user ${rhdmUserArray[0]}"
    createUser ${rhdmUserArray[0]} ${rhdmUserArray[1]} ${rhdmUserArray[2]} 
  done

  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
  rm -rf $RHDM_HOME/$RHDM_ROOT/standalone/data \
         $RHDM_HOME/$RHDM_ROOT/standalone/log \
         $RHDM_HOME/$RHDM_ROOT/standalone/tmp
fi

# append standalone.conf to bin/standalone.conf if needed
if ! grep -q "### Dynamic Resources ###" "$RHDM_HOME/$RHDM_ROOT/bin/standalone.conf"; then
  cat $CONTAINER_SCRIPTS_PATH/standalone.conf >> $RHDM_HOME/$RHDM_ROOT/bin/standalone.conf
fi

# remove unwanted deployments
if [ ! "$DECISION_CENTRAL" = "true" ];
then
  rm -f $RHDM_HOME/$RHDM_ROOT/standalone/deployments/decision-central.war.*
else
  rm -f $RHDM_HOME/$RHDM_ROOT/standalone/deployments/decision-central.war.*
  touch $RHDM_HOME/$RHDM_ROOT/standalone/deployments/decision-central.war.dodeploy
fi

if [ ! "$KIE_SERVER" = "true" ];
then
  rm -f $RHDM_HOME/$RHDM_ROOT/standalone/deployments/kie-server.war.*
else
  rm -f $RHDM_HOME/$RHDM_ROOT/standalone/deployments/kie-server.war.*
  touch $RHDM_HOME/$RHDM_ROOT/standalone/deployments/kie-server.war.dodeploy
fi

# add additional libraries to decision-central or kie-server deployment
for i in $(compgen -A variable | grep "^RHDM_LIB_");
  do
    IFS=':' read -a gav <<< "${!i}"
    gav_lib=${gav[1]}-${gav[2]}.jar
    gav_url="$NEXUS_URL/nexus/service/local/artifact/maven/redirect?r=public&g=${gav[0]}&a=${gav[1]}&v=${gav[2]}&e=jar"
    if [ "$KIE_SERVER" = "true" ]; then
      if [ ! -f $RHDM_HOME/$RHDM_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} ]; then
        echo "Installing library ${gav_lib} in kie-server"
        curl --insecure -s -L -o $RHDM_HOME/$RHDM_ROOT/standalone/deployments/kie-server.war/WEB-INF/lib/${gav_lib} \
             "$gav_url"
      fi
    fi
  done

# KIE-server in managed mode
if [ "$KIE_SERVER_MANAGED" = "true" ] 
then
  configure_controller_access
fi

# Business Central as KIE controller
if [ "$KIE_SERVER_CONTROLLER" = "true" -a "$DECISION_CENTRAL" = "true" ]
then
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.user=${KIESERVER_USER}"
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.pwd=${KIE_SERVER_PWD}"
fi

if [ "$KIE_SERVER" = "true" ]
then
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.id=kie-server-$KIE_SERVER_ID"
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.location=http://${IPADDR}:8080/kie-server/services/rest/server"
  RHDM_OPTS="$RHDM_OPTS -Dorg.drools.server.ext.disabled=$RHDM_EXT_DISABLED"
  RHDM_OPTS="$RHDM_OPTS -Dorg.optaplanner.server.ext.disabled=$BRP_EXT_DISABLED"
  RHDM_OPTS="$RHDM_OPTS -Dorg.jbpm.ui.server.ext.disabled=true" 
  RHDM_OPTS="$RHDM_OPTS -Dorg.jbpm.case.server.ext.disabled=true"
  RHDM_OPTS="$RHDM_OPTS -Dorg.jbpm.server.ext.disabled=true"
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.repo=$RHDM_DATA/configuration"
  RHDM_OPTS="$RHDM_OPTS -Dorg.drools.server.filter.classes=$KIE_SERVER_FILTER_CLASSES"
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.server.sync.deploy=$KIE_SERVER_SYNC_DEPLOY"
fi

# business-central
if [ "$DECISION_CENTRAL_DESIGN" = "true" -a "$DECISION_CENTRAL" = "true" ]
then
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.ssh.enabled=true"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.ssh.algorithm=RSA"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=true"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.daemon.host=$IPADDR"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.ssh.host=$IPADDR"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.ext.security.management.api.userManagementServices=WildflyCLIUserManagementService"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.host=$IPADDR"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.port=9990"
elif [ "$DECISION_CENTRAL" = "true" ]
then
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.ssh.enabled=false"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.daemon.enabled=false"
fi

if [ "$DECISION_CENTRAL" = "true" ]
then
  RHDM_OPTS="$RHDM_OPTS -Dorg.jbpm.designer.perspective=ruleflow -Ddesignerdataobjects=false"
  RHDM_OPTS="$RHDM_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_REPO"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.dir=$GIT_REPO"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.nio.git.ssh.cert.dir=$GIT_REPO"
  RHDM_OPTS="$RHDM_OPTS -Dorg.uberfire.metadata.index.dir=$GIT_REPO"
  RHDM_OPTS="$RHDM_OPTS -Ddatasource.management.wildfly.host=$IPADDR"
  RHDM_OPTS="$RHDM_OPTS -Dorg.kie.demo=$KIE_EXAMPLE -Dorg.kie.example=$KIE_EXAMPLE"
fi

# maven settings
RHDM_OPTS="$RHDM_OPTS -Dkie.maven.settings.custom=$MAVEN_SETTINGS"

SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.management=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.bind.address.insecure=$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.node.name=server-$IPADDR"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.config.dir=$RHDM_DATA/configuration"
SERVER_OPTS="$SERVER_OPTS -Djboss.server.deploy.dir=$RHDM_DATA/content"
SERVER_OPTS="$SERVER_OPTS --server-config=$JBOSS_CONFIG"

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

eval "exec $RHDM_HOME/$RHDM_ROOT/bin/standalone.sh $RHDM_OPTS $SERVER_OPTS \"\$@\""
