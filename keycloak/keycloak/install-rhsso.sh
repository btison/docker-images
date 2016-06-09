#!/bin/bash

. env.sh

FORCE=false

while [ "$#" -gt 0 ]
do
    case "$1" in
      --force)
          FORCE=true
          ;;  
      --)
          shift
          break;;
    esac
    shift
done

# Sanity Checks
if [ -f $KEYCLOAK ];
then
    echo "File $KEYCLOAK found"
else
    echo "File $KEYCLOAK not found. Please put it in the resources folder"
    exit 255
fi

if [ -f $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR ];
then
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR found"
else
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR not found. Please put it in the resources folder"
    exit 255
fi

if [ -d $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG ] || [ -d $SERVER_INSTALL_DIR/$SERVER_NAME ];
then
  if [ $FORCE = "true" ] ;
    then
      echo "Removing existing installation"
      rm -rf $SERVER_INSTALL_DIR/*
    else  
      echo "Target directory already exists. Please remove it before installing BPMS again."
      exit 250
  fi 
fi

# Install rhsso
echo "Unzipping rh-sso Server"
unzip -q $KEYCLOAK -d $SERVER_INSTALL_DIR

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG $SERVER_INSTALL_DIR/$SERVER_NAME

# Admin user
echo "Create rh-sso admin user"
cp $CONFIGURATION_DIR/rhsso/keycloak-add-user.json $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration

echo "Create management user admin:admin"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties | grep "admin=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
  echo "admin=c22052286cd5d72239a90fe193737253" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
fi

echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

# Configure the server
echo "Configure the Server"
# replace placeholders in cli file
VARS=( MYSQL_MODULE_NAME MYSQL_DRIVER_JAR MYSQL_DRIVER_JAR_DIR )
for i in "${VARS[@]}"
do
    sed -i "s'@@${i}@@'${!i}'" $CLI_RHSSO 
done
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh --file=$CLI_RHSSO"

exit 0
