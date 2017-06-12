#!/bin/bash
#
# This script runs the Jenkins server inside the Docker container.
# It copies the configuration and plugins from /opt/jenkins/configuration to
# ${JENKINS_HOME}.
#
# It also sets the admin password to ${JENKINS_PASSWORD}.
#
source /usr/local/bin/jenkins-common.sh

image_config_dir="/opt/jenkins/configuration"
image_config_path="${image_config_dir}/config.xml"

CONTAINER_MEMORY_IN_BYTES=`cat /sys/fs/cgroup/memory/memory.limit_in_bytes`
DEFAULT_MEMORY_CEILING=$((2**40-1))
if [ "${CONTAINER_MEMORY_IN_BYTES}" -lt "${DEFAULT_MEMORY_CEILING}" ]; then

    if [ -z $CONTAINER_HEAP_PERCENT ]; then
        CONTAINER_HEAP_PERCENT=0.50
    fi
    
    CONTAINER_MEMORY_IN_MB=$((${CONTAINER_MEMORY_IN_BYTES}/1024**2))
    
    JAVA_MAX_HEAP_PARAM="-Xmx${CONTAINER_HEAP_MAX}m"
    if [ -z $CONTAINER_INITIAL_PERCENT ]; then
      # jboss default was 100% or ms==mx
      JAVA_INITIAL_HEAP_PARAM="-Xms${CONTAINER_HEAP_MAX}m"
    else
      CONTAINER_INITIAL_HEAP=$(echo "${CONTAINER_HEAP_MAX} ${CONTAINER_INITIAL_PERCENT}" | awk '{ printf "%d", $1 * $2 }')
      JAVA_INITIAL_HEAP_PARAM="-Xms${CONTAINER_INITIAL_HEAP}m"
    fi
fi 

if [ -z $JAVA_GC_OPTS ]; then
  # note - MaxPermSize no longer valid with v8 of the jdk ... used to have -XX:MaxPermSize=100m
  JAVA_GC_OPTS="-XX:+UseParallelGC -XX:MinHeapFreeRatio=20 -XX:MaxHeapFreeRatio=40 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:MaxMetaspaceSize=100m"
fi

if [ ! -z "${USE_JAVA_DIAGNOSTICS}" ]; then
    JAVA_DIAGNOSTICS="-XX:NativeMemoryTracking=summary -XX:+PrintGC -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UnlockDiagnosticVMOptions"
fi

if [ ! -z "${CONTAINER_CORE_LIMIT}" ]; then
    JAVA_CORE_LIMIT="-XX:ParallelGCThreads=${CONTAINER_CORE_LIMIT} -Djava.util.concurrent.ForkJoinPool.common.parallelism=${CONTAINER_CORE_LIMT} -XX:CICompilerCount=2"
fi

# Since OpenShift runs this Docker image under random user ID, we have to assign
# the 'jenkins' user name to this UID.
# generate_passwd_file

mkdir /tmp/war
unzip -q /usr/lib/jenkins/jenkins.war -d /tmp/war
if [ -e ${JENKINS_HOME}/password ]; then
  old_salt=$(cat ${JENKINS_HOME}/password | sed 's/:.*//')
fi
new_password_hash=`obfuscate_password ${JENKINS_PASSWORD:-password} $old_salt`

# finish the move of the default logs dir, /var/log/jenkins, to the volume mount
# mkdir ${JENKINS_HOME}/logs
# ln -sf ${JENKINS_HOME}/logs /var/log/jenkins

JNLP_PORT=${JNLP_PORT:-50000}

if [ ! -e ${JENKINS_HOME}/configured ]; then
  # This container hasn't been configured yet, so copy the default configuration from
  # the image into the jenkins config path (which should be a volume for persistence).
  if [ ! -f "${image_config_path}" ]; then
    # If it contains a template (tpl) file, we can do additional manipulations to customize
    # the configuration.
    if [ -f "${image_config_path}.tpl" ]; then
    #  export KUBERNETES_CONFIG=$(generate_kubernetes_config)
    #  for name in $(get_is_names); do
    #    echo "Adding image ${name}:latest as Kubernetes slave ..."
    #  done
    #  echo "Generating kubernetes-plugin configuration (${image_config_path}.tpl) ..."
      envsubst < "${image_config_path}.tpl" > "${image_config_path}"
    fi
  fi

  if [ ! -f "${image_config_dir}/credentials.xml" ]; then
    if [ -f "${image_config_dir}/credentials.xml.tpl" ]; then
      #if [ ! -z "${KUBERNETES_CONFIG}" ]; then
      #  echo "Generating kubernetes-plugin credentials (${JENKINS_HOME}/credentials.xml.tpl) ..."
      #  export KUBERNETES_CREDENTIALS=$(generate_kubernetes_credentials)
      #fi
      # Fix the envsubst trying to substitute the $Hash inside credentials.xml
      #export Hash="\$Hash"
      envsubst < "${image_config_dir}/credentials.xml.tpl" > "${image_config_dir}/credentials.xml"
    fi
  fi

  echo "Copying Jenkins configuration to ${JENKINS_HOME} ..."
  cp -r /opt/jenkins/configuration/* ${JENKINS_HOME}
  rm -rf /opt/jenkins/configuration/*


  # If the INSTALL_PLUGINS variable is populated, then attempt to install
  # those plugins before copying them over to JENKINS_HOME
  # The format of the INSTALL_PLUGINS variable is a comma-separated list
  # of pluginId:pluginVersion strings
  if [[ -n "${INSTALL_PLUGINS:-}" ]]; then
    echo "Installing additional plugins: ${INSTALL_PLUGINS} ..."

    # Create a temporary file in the format of plugins.txt
    plugins_file=$(mktemp)
    IFS=',' read -ra plugins <<< "${INSTALL_PLUGINS}"
    for plugin in "${plugins[@]}"; do
        echo "${plugin}" >> "${plugins_file}"
    done

    # Call install plugins with the temporary file
    /usr/local/bin/install-plugins.sh "${plugins_file}"
  fi

  if [ "$(ls -A /opt/jenkins/plugins 2>/dev/null)" ]; then
    mkdir -p ${JENKINS_HOME}/plugins
    echo "Copying $(ls /opt/jenkins/plugins | wc -l) Jenkins plugins to ${JENKINS_HOME} ..."
    cp -r /opt/jenkins/plugins/* ${JENKINS_HOME}/plugins/
    rm -rf /opt/jenkins/plugins
  fi

  echo "Creating initial Jenkins 'admin' user ..."
  sed -i "s,<passwordHash>.*</passwordHash>,<passwordHash>$new_password_hash</passwordHash>,g" "${JENKINS_HOME}/users/admin/config.xml"
  echo $new_password_hash > ${JENKINS_HOME}/password
  touch ${JENKINS_HOME}/configured
fi

if [ -e ${JENKINS_HOME}/password ]; then
  # if the password environment variable has changed, update the jenkins config.
  # we don't want to just blindly do this on startup because the user might change their password via
  # the jenkins ui, so we only want to do this if the env variable has been explicitly modified from
  # the original value.
  old_password_hash=`cat ${JENKINS_HOME}/password`
  if [ $old_password_hash != $new_password_hash ]; then
    echo "Detected password environment variable change, updating Jenkins configuration ..."
    sed -i "s,<passwordHash>.*</passwordHash>,<passwordHash>$new_password_hash</passwordHash>,g" "${JENKINS_HOME}/users/admin/config.xml"
    echo $new_password_hash > ${JENKINS_HOME}/password
  fi
fi

if [ -f "${CONFIG_PATH}.tpl" -a ! -f "${CONFIG_PATH}" ]; then
  echo "Processing Jenkins configuration (${CONFIG_PATH}.tpl) ..."
  envsubst < "${CONFIG_PATH}.tpl" > "${CONFIG_PATH}"
fi

rm -rf /tmp/war

# default log rotation in /etc/logrotate.d/jenkins handles /var/log/jenkins/access_log
if [ ! -z "${JENKINS_USE_ACCESS_LOG}" ]; then
    JENKINS_ACCESSLOG="--accessLoggerClassName=winstone.accesslog.SimpleAccessLogger --simpleAccessLogger.format=combined --simpleAccessLogger.file=/var/log/jenkins/access_log"
fi

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
   exec java $JAVA_GC_OPTS $JAVA_INITIAL_HEAP_PARAM $JAVA_MAX_HEAP_PARAM -Duser.home=${HOME} $JAVA_CORE_LIMIT $JAVA_DIAGNOSTICS $JAVA_OPTS -Dfile.encoding=UTF8 -jar /usr/lib/jenkins/jenkins.war $JENKINS_OPTS $JENKINS_ACCESSLOG "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"