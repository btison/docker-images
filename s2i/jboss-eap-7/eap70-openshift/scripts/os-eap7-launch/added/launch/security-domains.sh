
function prepareEnv() {
  unset SECDOMAIN_NAME
  unset SECDOMAIN_USERS_PROPERTIES
  unset SECDOMAIN_ROLES_PROPERTIES
  unset SECDOMAIN_LOGIN_MODULE
  unset SECDOMAIN_PASSWORD_STACKING
}

function configure() {
  configure_security_domains
}

function configureEnv() {
  configure
}

configure_security_domains() {
  domains="<!-- no additional security domains configured -->"
  if [ -n "$SECDOMAIN_NAME" ]; then
      local configDir=${JBOSS_HOME}/standalone/configuration
      if [ -f "${configDir}/${SECDOMAIN_USERS_PROPERTIES}" -a -f "${configDir}/${SECDOMAIN_ROLES_PROPERTIES}" ] ; then
          local login_module=${SECDOMAIN_LOGIN_MODULE:-UsersRoles}

          if [ $login_module == "RealmUsersRoles" ]; then
            local realm="<module-option name=\"realm\" value=\"ApplicationRealm\"/>"
          else
            local realm=""
          fi

          if [ -n "$SECDOMAIN_PASSWORD_STACKING" ]; then
              stack="<module-option name=\"password-stacking\" value=\"useFirstPass\"/>"
          else
              stack=""
          fi
          domains="\
            <security-domain name=\"$SECDOMAIN_NAME\" cache-type=\"default\">\
                <authentication>\
                    <login-module code=\"$login_module\" flag=\"required\">\
                        <module-option name=\"usersProperties\" value=\"\${jboss.server.config.dir}/$SECDOMAIN_USERS_PROPERTIES\"/>\
                        <module-option name=\"rolesProperties\" value=\"\${jboss.server.config.dir}/$SECDOMAIN_ROLES_PROPERTIES\"/>\
                        $realm\
                        $stack\
                    </login-module>\
                </authentication>\
            </security-domain>"
      else
          echo "WARNING! Both user and roles files must exist before an additional security domain can be configured, current values are ${SECDOMAIN_USERS_PROPERTIES} and ${SECDOMAIN_ROLES_PROPERTIES}."
      fi
  fi

  if [ -n "$domains" ]; then
    sed -i "s|<!-- ##ADDITIONAL_SECURITY_DOMAINS## -->|${domains}<!-- ##ADDITIONAL_SECURITY_DOMAINS## -->|" "$CONFIG_FILE"
  fi
}
