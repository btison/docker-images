#!/bin/bash

. env.sh

# Sanity Checks
if [ -f $EAP ];
then
    echo "File $EAP found"
else
    echo "File $EAP not found. Please put it in the resources folder"
    exit 255
fi

if [ -f $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR ];
then
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR found"
else
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR not found. Please put it in the resources folder"
    exit 255
fi

if [ -d $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG ] || [ -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Target directory already exists. Please remove it before installing EAP again."
  exit 250
fi

# Install eap
echo "Unzipping EAP 6"
unzip -q $EAP -d $SERVER_INSTALL_DIR

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG $SERVER_INSTALL_DIR/$SERVER_NAME

echo "Create application users admin:admin & user:user"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "admin=207b6e0cc556d7084b5e2db7d822555c" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "user=c5568adea472163dfc00c19c6348a665" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
fi

RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "admin=admin,guest" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "user=user,guest" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
fi

echo "Create management user admin:admin"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties | grep "admin=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
  echo "admin=c22052286cd5d72239a90fe193737253" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
fi

# MySQL module
echo "Configure mysql module"
MYSQL_MODULE_DIR=$(echo $MYSQL_MODULE_NAME | sed -e "s:\.:/:g")
mkdir -p $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/$MYSQL_MODULE_DIR/main
cp $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/$MYSQL_MODULE_DIR/main
cp $MYSQL_MODULE $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/$MYSQL_MODULE_DIR/main
MYSQL_VARS=( MYSQL_MODULE_NAME MYSQL_DRIVER_JAR )
for i in "${MYSQL_VARS[@]}"
do
  sed -i "s'@@${i}@@'${!i}'" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/$MYSQL_MODULE_DIR/main/module.xml	
done

echo "Change owner to user jboss"
chown jboss:jboss $SERVER_INSTALL_DIR
chown -R jboss:jboss $SERVER_INSTALL_DIR/$SERVER_NAME

# Configure the server
#echo "Configure the Server"
#su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.sh --admin-only -c $JBOSS_CONFIG &"
#sleep 15
#su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_JBPM_DS"
#su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 \":shutdown\" "
#sleep 10

exit 0
