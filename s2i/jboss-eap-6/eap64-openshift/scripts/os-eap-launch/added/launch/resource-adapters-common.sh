source $JBOSS_HOME/bin/launch/launch-common.sh

function clearResourceAdapterEnv() {
  local prefix=$1

  unset ${prefix}_ID
  unset ${prefix}_MODULE_SLOT
  unset ${prefix}_MODULE_ID
  unset ${prefix}_CONNECTION_CLASS
  unset ${prefix}_CONNECTION_JNDI

  for xa_prop in $(compgen -v | grep -s "${prefix}_PROPERTY_"); do
    unset ${xa_prop}
  done
}

function clearResourceAdaptersEnv() {
  for ra_prefix in $(echo $RESOURCE_ADAPTERS | sed "s/,/ /g"); do
    clearResourceAdapterEnv $ra_prefix
  done
  unset RESOURCE_ADAPTERS
}

function inject_resource_adapters_common() {

  resource_adapters=
  
  hostname=`hostname`

  for ra_prefix in $(echo $RESOURCE_ADAPTERS | sed "s/,/ /g"); do
    ra_id=$(find_env "${ra_prefix}_ID")
    if [ -z "$ra_id" ]; then
      echo "Warning - ${ra_prefix}_ID is missing from resource adapter configuration, defaulting to ${ra_prefix}"
      ra_id="${ra_prefix}"
    fi

    ra_module_slot=$(find_env "${ra_prefix}_MODULE_SLOT")
    if [ -z "$ra_module_slot" ]; then
      echo "Warning - ${ra_prefix}_MODULE_SLOT is missing from resource adapter configuration, defaulting to main"
      ra_module_slot="main"
    fi

    ra_module_id=$(find_env "${ra_prefix}_MODULE_ID")
    if [ -z "$ra_module_id" ]; then
      echo "Warning - ${ra_prefix}_MODULE_ID is missing from resource adapter configuration. Resource adapter will not be configured"
      continue
    fi

    ra_class=$(find_env "${ra_prefix}_CONNECTION_CLASS")
    if [ -z "$ra_class" ]; then
      echo "Warning - ${ra_prefix}_CONNECTION_CLASS is missing from resource adapter configuration. Resource adapter will not be configured"
      continue
    fi

    ra_jndi=$(find_env "${ra_prefix}_CONNECTION_JNDI")
    if [ -z "$ra_jndi" ]; then
      echo "Warning - ${ra_prefix}_CONNECTION_JNDI is missing from resource adapter configuration. Resource adapter will not be configured"
      continue
    fi

    resource_adapter="<resource-adapter id=\"$ra_id\"><module slot=\"$ra_module_slot\" id=\"$ra_module_id\"></module><connection-definitions><connection-definition class-name=\"${ra_class}\" jndi-name=\"${ra_jndi}\" enabled=\"true\" use-java-context=\"true\">"

    ra_props=$(compgen -v | grep -s "${ra_prefix}_PROPERTY_")
    if [ -n "$ra_props" ]; then
      for ra_prop in $(echo $ra_props); do
        prop_name=$(echo "${ra_prop}" | sed -e "s/${ra_prefix}_PROPERTY_//g")
        prop_val=$(find_env $ra_prop)

        resource_adapter="${resource_adapter}<config-property name=\"${prop_name}\">${prop_val}</config-property>"
      done
    fi

    resource_adapter="${resource_adapter}</connection-definition></connection-definitions></resource-adapter>"

    resource_adapters="${resource_adapters}${resource_adapter}"
  done

  if [ -n "$resource_adapters" ]; then
    resource_adapters=$(echo "${resource_adapters}" | sed -e "s/localhost/${hostname}/g")
    sed -i "s|<!-- ##RESOURCE_ADAPTERS## -->|${resource_adapters}<!-- ##RESOURCE_ADAPTERS## -->|" $CONFIG_FILE
  fi
}

