#!/bin/bash

. /env.sh

echo "Installing the camel-twitter module"
T1=$( echo $MODULE_CAMEL_TWITTER | sed 's/\./\//g' )
mkdir -p $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T1/main
cp $CONFIGURATION_DIR/$MODULE_CAMEL_TWITTER_MODULE_DIR/module.xml $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T1/main
cp $RESOURCES_DIR/$MODULE_CAMEL_TWITTER_MODULE_DIR/*.jar $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T1/main
sed -i "s/@@module_camel_twitter@@/$MODULE_CAMEL_TWITTER/" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T1/main/module.xml
sed -i "s/@@module_camel_twitter_camel_twitter_jar@@/$MODULE_CAMEL_TWITTER_CAMEL_TWITTER_JAR/" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T1/main/module.xml

# Twitter4j module
echo "Installing the twitter4j module"
T2=$( echo $MODULE_TWITTER4J | sed 's/\./\//g' )
mkdir -p $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main
cp $CONFIGURATION_DIR/$MODULE_TWITTER4J_MODULE_DIR/module.xml $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main
cp $RESOURCES_DIR/$MODULE_TWITTER4J_MODULE_DIR/*.jar $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main
sed -i "s/@@module_twitter4j@@/$MODULE_TWITTER4J/" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main/module.xml
sed -i "s/@@module_twitter4j_twitter4j_core_jar@@/$MODULE_TWITTER4J_TWITTER4J_CORE_JAR/" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main/module.xml
sed -i "s/@@module_twitter4j_twitter4j_stream_jar@@/$MODULE_TWITTER4J_TWITTER4J_STREAM_JAR/" $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/$T2/main/module.xml

# make csv input dir
echo "Create CSV input dir"
mkdir -p $ANGRYTWEET_CSVINPUTDIR

# configure crm application
echo "Configure crm application"
cp $CONF_PROPERTIES_CRM $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration

# deploy angrytweet application
echo "Deploy angrytweet application"
cp $APP_ANGRYTWEET_SY $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments
cp $APP_ANGRYTWEET_CRM $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments

# deploy angrytweet ip app
echo "Deploy angrytweet ip app"
cp $APP_ANGRYTWEET_IP $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments

# restore ownership
chown -R jboss:jboss $SERVER_INSTALL_DIR

# Configure the server
echo "Configure FSW for Angrytweet application"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.sh --admin-only -c $JBOSS_CONFIG &"
sleep 20
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_ANGRYTWEET_DS"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_MODULE_CAMEL_TWITTER"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 :shutdown"
sleep 10

exit 0
