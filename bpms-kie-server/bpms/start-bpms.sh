#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

echo "IPADDR = $IPADDR"

MYSQL_HOST_IP=$(ping -q -c 1 -t 1 mysql | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
MYSQL_HOST_PORT=3306
NEXUS_IP=$(ping -q -c 1 -t 1 nexus | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
NEXUS_PORT=8080
NEXUS_URL=$NEXUS_IP:$NEXUS_PORT

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "BPMS not installed."
  exit 0
fi

CLEAN=false
DEBUG_MODE=true
DEBUG_PORT="8787"
SERVER_OPTS=""
ADMIN_ONLY=""

while [ "$#" -gt 0 ]
do
    case "$1" in
      --debug)
          DEBUG_MODE=true
          shift
          if [ -n "$1" ] && [ "${1#*-}" = "$1" ]; then
              DEBUG_PORT=$1
          fi
          ;;
      --admin-only)
          ADMIN_ONLY=--admin-only
          ;;
      --clean)
          CLEAN=true
          ;; 
      --)
          shift
          break;;
      *)
          SERVER_OPTS="$SERVER_OPTS \"$1\""
          ;;
    esac
    shift
done

# Set debug settings if not already set
if [ "$DEBUG_MODE" = "true" ]; then
    SERVER_OPTS="$SERVER_OPTS --debug ${DEBUG_PORT}"
fi

# setup quartz
if [ ! "$QUARTZ" = "true" ];
then
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/$(basename $QUARTZ_PROPERTIES)
fi

# configuration
if [ ! -d "$BPMS_DATA_DIR/configuration" ]; then
  mkdir -p $BPMS_DATA_DIR
  mkdir -p $BPMS_DATA_DIR/content
  cp -r $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration $BPMS_DATA_DIR
  chown -R jboss:jboss $BPMS_DATA_DIR
  CLEAN="true"
fi

# Clean data, log and temp directories
if [ "$CLEAN" = "true" ] 
then
    rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/data $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/log $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/tmp
fi

# remove unwanted deployments
if [ ! "$BUSINESS_CENTRAL" == "true" ];
then
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war.*
else
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war.*
  touch $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war.dodeploy
fi

if [ ! "$KIE_SERVER" == "true" ];
then
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war.*
else
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war.*
  touch $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war.dodeploy
fi

if [ ! "$DASHBOARD" == "true" ];
then
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war.*
else
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war.*
  touch $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war.dodeploy
fi

# setup nexus
sed -r -i "s'[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{1,5}'$NEXUS_URL'g" $BPMS_DATA_DIR/configuration/$(basename $MAVEN_SETTINGS_XML)

# start options
BPMS_OPTS=""

if [ ! "$EXECUTOR" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.disabled=true"
fi

if [ ! "$EXECUTOR_JMS" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.executor.jms=false"
fi

if [ "$KIE_SERVER_MANAGED" == "true" ] 
then
  KIE_SERVER_CONTROLLER_IP=$(ping -q -c 1 -t 1 ${KIE_SERVER_CONTROLLER} | grep -m 1 PING | cut -d "(" -f2 | cut -d ")" -f1)
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller=http://${KIE_SERVER_CONTROLLER_IP}:8080/business-central/rest/controller"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller.user=kieserver"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.controller.pwd=kieserver1!"
fi

if [ "$KIE_SERVER_CONTROLLER" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.user=admin1"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.pwd=admin"
fi

if [ "$KIE_SERVER" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.id=kie-server-$KIE_SERVER_ID"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.location=http://${IPADDR}:8080/kie-server/services/rest/server"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.persistence.ds=java:jboss/datasources/jbpmDS"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.server.ext.disabled=$BPMS_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.drools.server.ext.disabled=$BRMS_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.optaplanner.server.ext.disabled=$BRP_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ui.server.ext.disabled=$JBPMUI_EXT_DISABLED"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.repo=$BPMS_DATA_DIR/configuration"
  BPMS_OPTS="$BPMS_OPTS -Dorg.kie.server.bypass.auth.user=$KIE_SERVER_BYPASS_AUTH_USER"
fi

if [ ! -f ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties -a "$KIE_SERVER" == "true" ]
then
  # userinfo properties file
  touch ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
  echo "busadmin=busadmin@example.com:en-UK:busadmin" >> ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
  echo "user1=user1@example.com:en-UK:user1" >> ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
  echo "reviewer=:en-UK:reviewer:[user1]" >> ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
  echo "Administrator=admin@example.com.org:en-UK:Administrator" >> ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
  echo "Administrators=:en-UK:Administrators:[busadmin]" >> ${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties
fi

if [ "$KIE_SERVER_BYPASS_AUTH_USER" == "true" -a "$KIE_SERVER" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.callback=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.group.mapping=file:$BPMS_DATA_DIR/configuration/application-roles.properties"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.userinfo=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.info.properties=file:${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties"
elif [ "$KIE_SERVER" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.callback=jaas"
  BPMS_OPTS="$BPMS_OPTS -Dorg.jbpm.ht.userinfo=props"
  BPMS_OPTS="$BPMS_OPTS -Djbpm.user.info.properties=file:${BPMS_DATA_DIR}/configuration/jbpm-userinfo.properties"
fi

if [ "$BUSINESS_CENTRAL_DESIGN" == "true" ]
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.enabled=true"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.enabled=true"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.api.userManagementServices=WildflyCLIUserManagementService"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.host=$IPADDR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.ext.security.management.wildfly.cli.port=9999"
else
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.ssh.enabled=false"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.daemon.enabled=false"
fi

if [ "$BUSINESS_CENTRAL" == "true" ];
then
  BPMS_OPTS="$BPMS_OPTS -Dorg.guvnor.m2repo.dir=$BPMS_DATA_DIR/$MAVEN_DIR/repository"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.nio.git.dir=$BPMS_DATA_DIR/$REPO_DIR"
  BPMS_OPTS="$BPMS_OPTS -Dorg.uberfire.metadata.index.dir=$BPMS_DATA_DIR/$REPO_DIR"
fi

# start bpms

if [ "$START_BPMS" == "false" ] 
then
  exit 0
fi


sudo -u jboss \
    nohup ${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/standalone.sh \
    -Djboss.bind.address=$IPADDR \
    -Djboss.bind.address.management=$IPADDR \
    -Djboss.bind.address.insecure=$IPADDR \
    -Djboss.node.name=server-$IPADDR \
    -Djboss.server.config.dir=$BPMS_DATA_DIR/configuration \
    -Djboss.server.deploy.dir=$BPMS_DATA_DIR/content \
    -Dmysql.host.ip=$MYSQL_HOST_IP \
    -Dmysql.host.port=$MYSQL_HOST_PORT \
    -Dmysql.bpms.schema=$MYSQL_BPMS_SCHEMA \
    -Dkie.maven.settings.custom=$BPMS_DATA_DIR/configuration/$(basename $MAVEN_SETTINGS_XML) \
    $BPMS_OPTS \
    --server-config=$JBOSS_CONFIG $ADMIN_ONLY $SERVER_OPTS 0<&- &>/dev/null &
echo "BPMS started"
 
