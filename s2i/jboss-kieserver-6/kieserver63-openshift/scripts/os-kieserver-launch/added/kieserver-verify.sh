#!/bin/sh
# if using vim, do ':set ft=zsh' for easier reading

# source the KIE config
. $JBOSS_HOME/bin/kieserver-config.sh
# set the KIE environment
setKieContainerEnv
# dump the KIE environment
dumpKieContainerEnv

function verifyContainers() {
    releaseIds=""
    for (( i=0; i<${KIE_CONTAINER_DEPLOYMENT_COUNT}; i++ )); do
        groupId=$(getKieContainerVal KJAR_GROUP_ID ${i})
        artifactId=$(getKieContainerVal KJAR_ARTIFACT_ID ${i})
        version=$(getKieContainerVal KJAR_VERSION ${i})
        releaseIds="${releaseIds} ${groupId}:${artifactId}:${version}"
    done
    containerVerifier="org.openshift.kieserver.common.server.ContainerVerifier"
    echo "Attempting to verify containers with 'java ${containerVerifier} ${releaseIds}'"
    java -cp $(getKieClassPath) ${containerVerifier} ${releaseIds}
}

# Execute the container verification
verifyContainers
ERR=$?

if [ $ERR -ne 0 ]; then
  echo "Aborting due to error code $ERR from container verification"
  exit $ERR
fi

# Necessary to permit running with a randomised UID
chown -R jboss:root ${HOME}/.m2/repository
chmod -R g+rwX ${HOME}/.m2/repository

exit 0
