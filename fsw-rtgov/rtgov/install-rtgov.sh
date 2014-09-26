#!/bin/bash

. /env.sh

# Sanity checks
if [ -f $FSW ];
then
  echo "File $FSW found"
else
  echo "File $FSW does not exists. Please put it in the resources folder"
  exit 255
fi

if [ -f $FSW_PATCH_ZIP ];
then
  echo "File $FSW_PATCH_ZIP found"
else
  echo "File $FSW_PATCH_ZIP does not exist. Please put it in the resources folder"
  exit 255
fi

if [ -f $MYSQL_DRIVER ];
then
    echo "File $MYSQL_DRIVER found"
else
    echo "File $MYSQL_DRIVER not found. Please put it in the resources folder"
    exit 255
fi

if [ -d $SERVER_INSTALL_DIR/jboss-eap-6.1 ] || [ -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Target directory already exists. Please remove it before installing FSW again."
  exit 250
fi

#Setup FSW configuration file
cp $FSW_INSTALL_MANIFEST $TEMP_DIR

VARS=( SERVER_INSTALL_DIR MYSQL_DRIVER MYSQL_SCHEMA )
for i in "${VARS[@]}"
do
    sed -i "s'@@${i}@@'${!i}'" /$TEMP_DIR/$(basename $FSW_INSTALL_MANIFEST)	
done

#Install FSW
echo "Installing FSW"
java -jar $FSW /tmp/$(basename $FSW_INSTALL_MANIFEST) -variablefile $FSW_INSTALL_VARIABLES 

#Check successful install
SUCCESS=$(cat $SERVER_INSTALL_DIR/InstallationLog.txt | grep 'Automated installation done')
if [ -z "$SUCCESS" ];
then
    echo "Installation of FSW failed. Check the installation log for details"
    exit 250
fi

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/jboss-eap-6.1 $SERVER_INSTALL_DIR/$SERVER_NAME

echo "Setting JBoss node name to ${SERVER_NODE_NAME}"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "jboss.node.name=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.node.name=${SERVER_NODE_NAME}\"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi

# Install missing modules
echo "Installing missing modules"
cp -r $RESOURCES_DIR/modules/* $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa

# Apply Rollup Patch 2
echo "Apply Fuse Service Works 6.0.0 Rollup Patch 2"
unzip $FSW_PATCH_ZIP -d $RESOURCES_DIR
# Base Installation
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ejb3/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/web/main/
unzip $FSW_PATCH_BASE -d $RESOURCES_DIR
mv $RESOURCES_DIR/jboss-eap-6.1 $RESOURCES_DIR/$SERVER_NAME
cp -r $RESOURCES_DIR/$SERVER_NAME $SERVER_INSTALL_DIR
rm -rf $RESOURCES_DIR/$SERVER_NAME 
# RTGOV
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-fileupload-1.2.2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xstream-1.4.3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/ip/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/epn/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/pom.xml
unzip $FSW_PATCH_RTGOV -d $RESOURCES_DIR
mv $RESOURCES_DIR/jboss-eap-6.1 $RESOURCES_DIR/$SERVER_NAME
cp -r $RESOURCES_DIR/$SERVER_NAME $SERVER_INSTALL_DIR
rm -rf $RESOURCES_DIR/$SERVER_NAME

# change owner to user jboss
echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

