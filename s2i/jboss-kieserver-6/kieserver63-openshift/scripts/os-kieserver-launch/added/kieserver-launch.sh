#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

# source the KIE config
. $JBOSS_HOME/bin/kieserver-config.sh
# set the KIE environment
setKieFullEnv
# dump the KIE environment
dumpKieFullEnv

function generateKieServerStateXml() {
    java -cp $(getKieClassPath) org.openshift.kieserver.common.server.ServerConfig xml
}

function filterKieJmsFile() {
    kieJmsFile="${1}"
    if [ -e ${kieJmsFile} ] ; then
        sed -i "s,queue/KIE\.SERVER\.REQUEST,${KIE_SERVER_JMS_QUEUES_REQUEST},g" ${kieJmsFile}
        sed -i "s,queue/KIE\.SERVER\.RESPONSE,${KIE_SERVER_JMS_QUEUES_RESPONSE},g" ${kieJmsFile}
        sed -i "s,queue/KIE\.SERVER\.EXECUTOR,${KIE_SERVER_EXECUTOR_JMS_QUEUE},g" ${kieJmsFile}
    fi
}

function filterQuartzPropFile() {
    quartzPropFile="${1}"
    if [ -e ${quartzPropFile} ] ; then
        if [[ "${KIE_SERVER_PERSISTENCE_DIALECT}" == "org.hibernate.dialect.MySQL"* ]]; then
            sed -i "s,org.quartz.jobStore.driverDelegateClass=,org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.StdJDBCDelegate," ${quartzPropFile}
            quartzDriverDelegateSet="true"
        elif [[ "${KIE_SERVER_PERSISTENCE_DIALECT}" == "org.hibernate.dialect.PostgreSQL"* ]]; then
            sed -i "s,org.quartz.jobStore.driverDelegateClass=,org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.PostgreSQLDelegate," ${quartzPropFile}
            quartzDriverDelegateSet="true"
        fi
        if [ "x${DB_JNDI}" != "x" ]; then
            sed -i "s,org.quartz.dataSource.managedDS.jndiURL=,org.quartz.dataSource.managedDS.jndiURL=${DB_JNDI}," ${quartzPropFile}
            quartzManagedJndiSet="true"
        fi
        if [ "x${QUARTZ_JNDI}" != "x" ]; then
            sed -i "s,org.quartz.dataSource.notManagedDS.jndiURL=,org.quartz.dataSource.notManagedDS.jndiURL=${QUARTZ_JNDI}," ${quartzPropFile}
            quartzNotManagedJndiSet="true"
        fi
        if [ "${quartzDriverDelegateSet}" = "true" ] && [ "${quartzManagedJndiSet=}" = "true" ] && [ "${quartzNotManagedJndiSet=}" = "true" ]; then
            KIE_SERVER_OPTS="${KIE_SERVER_OPTS} -Dorg.quartz.properties=${quartzPropFile}"
        fi
    fi
}

# generate the KIE Server state file
generateKieServerStateXml > "${KIE_SERVER_STATE_FILE}"

# filter the KIE Server kie-server-jms.xml and ejb-jar.xml files
filterKieJmsFile "${JBOSS_HOME}/standalone/deployments/kie-server.war/META-INF/kie-server-jms.xml"
filterKieJmsFile "${JBOSS_HOME}/standalone/deployments/kie-server.war/WEB-INF/ejb-jar.xml"

# filter the KIE Server quartz.properties file
filterQuartzPropFile "${JBOSS_HOME}/bin/quartz.properties"

# CLOUD-758 - "Provider com.sun.script.javascript.RhinoScriptEngineFactory not found" is logged every time when a process uses Java Script.
sed -i "s|com.sun.script.javascript.RhinoScriptEngineFactory||" $JBOSS_HOME/modules/system/layers/base/sun/jdk/main/service-loader-resources/META-INF/services/javax.script.ScriptEngineFactory

# append KIE Server options to JAVA_OPTS
echo "# Append KIE Server options to JAVA_OPTS" >> $JBOSS_HOME/bin/standalone.conf
echo "JAVA_OPTS=\"\$JAVA_OPTS ${KIE_SERVER_OPTS}\"" >> $JBOSS_HOME/bin/standalone.conf

# add the KIE Server user
$JBOSS_HOME/bin/add-user.sh -a -u "${KIE_SERVER_USER}" -p "${KIE_SERVER_PASSWORD}" -ro "kie-server,guest"

# execute the parent launch script
exec $JBOSS_HOME/bin/openshift-launch.sh
