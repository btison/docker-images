#!/bin/bash

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

# first run
if [ ! -e /var/lib/ldap/DB_CONFIG ]; then 
  FIRST_RUN=true
  echo "First run"
fi

if [ "$FIRST_RUN" = "true" ]
then
  # copy backend config file
  cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
  chown ldap:ldap /var/lib/ldap/DB_CONFIG

  # set config password
  LDAP_CONFIG_PASSWORD_ENCRYPTED=$(slappasswd -s $LDAP_CONFIG_PASSWORD)
  sed -i "s|@@LDAP_CONFIG_PASSWORD_ENCRYPTED@@|${LDAP_CONFIG_PASSWORD_ENCRYPTED}|g" ${CONTAINER_SCRIPTS_PATH}/ldif/chrootpw.ldif
  
  # set directory password
  LDAP_ADMIN_PASSWORD_ENCRYPTED=$(slappasswd -s $LDAP_ADMIN_PASSWORD)

  # configure domain
  VARS=( LDAP_BIND_CN LDAP_BASE_DN LDAP_ADMIN_PASSWORD_ENCRYPTED) 
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" ${CONTAINER_SCRIPTS_PATH}/ldif/domain.ldif	
  done 

  # configure base domain
  VARS=( LDAP_BIND_CN LDAP_BASE_DN LDAP_ORGANISATION LDAP_DOMAIN )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" ${CONTAINER_SCRIPTS_PATH}/ldif/basedomain.ldif
  done

  # start slapd in background
  /usr/sbin/slapd -u ldap -g ldap -h 'ldap:/// ldapi:///' &
  while [ ! -e /run/openldap/slapd.pid ]; do sleep 1; done

  # init ldap directory
  ldapadd -Y EXTERNAL -H ldapi:/// -f ${CONTAINER_SCRIPTS_PATH}/ldif/chrootpw.ldif
  ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
  ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
  ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
  ldapmodify -Y EXTERNAL -H ldapi:/// -f ${CONTAINER_SCRIPTS_PATH}/ldif/domain.ldif
  ldapadd -x -D cn=${LDAP_BIND_CN},${LDAP_BASE_DN} -w ${LDAP_ADMIN_PASSWORD} -f ${CONTAINER_SCRIPTS_PATH}/ldif/basedomain.ldif
  
  # shut down slapd
  SLAPD_PID=$(cat /run/openldap/slapd.pid)
  kill -15 $SLAPD_PID
  while [ -e /proc/$SLAPD_PID ]; do sleep 1; done # wait until slapd is terminated 
fi

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
ulimit -n 1024

/usr/sbin/slapd -h "ldap://${IPADDR} ldaps://${IPADDR} ldapi:///" -u ldap -g ldap -d $LDAP_LOG_LEVEL 0<&- &>/var/log/openldap