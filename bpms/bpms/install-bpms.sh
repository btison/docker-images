#!/bin/bash

. env.sh

FORCE=false

while [ "$#" -gt 0 ]
do
    case "$1" in
      --nexus)
          NEXUS=true
          ;;
      --no-nexus)
          NEXUS=false
          ;;
      --dashboard)
          DASHBOARD=true
          ;;
      --no-dashboard)
          DASHBOARD=false
          ;;
      --quartz)
          QUARTZ=true
          ;;
      --no-quartz)
          QUARTZ=false
          ;;
      --force)
          FORCE=true
          ;;  
      --)
          shift
          break;;
    esac
    shift
done

echo "NEXUS=$NEXUS"
echo "DASHBOARD=$DASHBOARD"
echo "QUARTZ=$QUARTZ"

# Sanity Checks
if [ -f $EAP ];
then
    echo "File $EAP found"
else
    echo "File $EAP not found. Please put it in the resources folder"
    exit 255
fi

if [ -f $BPMS ];
then
    echo "File $BPMS found"
else
    echo "File $BPMS not found. Please put it in the resources folder"
    exit 255
fi

if [ -f $EAP_PATCH_ZIP ];
then
    echo "File $EAP_PATCH_ZIP found"
else
    echo "File $EAP_PATCH_ZIP not found. Please put it in the resources folder"
    exit 255
fi

if [ -f $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR ];
then
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR found"
else
    echo "File $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR not found. Please put it in the resources folder"
    exit 255
fi

if [ -d $SERVER_INSTALL_DIR/jboss-eap-6.1 ] || [ -d $SERVER_INSTALL_DIR/$SERVER_NAME ];
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

# Install bpms
echo "Unzipping EAP 6"
unzip -q $EAP -d $SERVER_INSTALL_DIR

echo "Unzipping BPMS"
unzip -q -o $BPMS -d $SERVER_INSTALL_DIR

# Install Security patch
echo "Install security patch"
unzip -q -o $EAP_PATCH_ZIP -d $RESOURCES_DIR
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bin/client/jboss-cli-client.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bin/client/jboss-client.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bundles/system/layers/base/org/jboss/as/osgi/configadmin/main
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/docs/schema/module-1_3.xsd
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/jboss-modules.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/apache/xalan
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/fusesource/jansi
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/vfs
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/opensaml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/picketbox
unzip -q -o $EAP_PATCH -d $SERVER_INSTALL_DIR

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/jboss-eap-6.1 $SERVER_INSTALL_DIR/$SERVER_NAME

if [ ! "$DASHBOARD" == "true" ];
then
  echo "Removing dashboard app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war.dodeploy
fi

echo "Set system variables for BPMS"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "org.kie.example=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.kie.example=false \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi

echo "Set system variables for maven and git repos"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "org.guvnor.m2repo.dir=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.uberfire.nio.git.dir=$SERVER_INSTALL_DIR/$REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.uberfire.metadata.index.dir=$SERVER_INSTALL_DIR/$REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi 

echo "Set system variable for local Maven repo"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "kie.maven.settings.custom=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dkie.maven.settings.custom=$SERVER_INSTALL_DIR/$MAVEN_DIR/settings.xml \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi 

# Setup maven repo
mkdir -p $SERVER_INSTALL_DIR/$MAVEN_DIR/repository
if [ "$NEXUS" == "true" ]
then
  echo "Setup local maven repo with Nexus"
  cp $MAVEN_SETTINGS_XML $SERVER_INSTALL_DIR/$MAVEN_DIR/
  VARS=( NEXUS_URL MAVEN_REPO_DIR )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $SERVER_INSTALL_DIR/$MAVEN_DIR/$(basename $MAVEN_SETTINGS_XML)	
  done      
else
  echo "Setup local maven repo off-line"
  touch $SERVER_INSTALL_DIR/$MAVEN_DIR/settings.xml
  echo "<settings><localRepository>$MAVEN_REPO_DIR</localRepository><offline>true</offline></settings>" >> $SERVER_INSTALL_DIR/$MAVEN_DIR/settings.xml
fi

echo "Create application users admin1:admin & user:user"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "admin1=8b68b1984bd2f4faf6b7a3c6a0c78968" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "user=c5568adea472163dfc00c19c6348a665" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
fi

RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "admin1=admin,analyst,user,reviewer" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "user=user,reviewer" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
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

# Create directories and set permissions
echo "Make directories for maven and git repo"
mkdir -p $SERVER_INSTALL_DIR/${REPO_DIR}

# Quartz Properties
echo "Copy quartz properties file"
cp $QUARTZ_PROPERTIES $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration

echo "Change owner to user jboss"
chown jboss:jboss $SERVER_INSTALL_DIR
chown -R jboss:jboss $SERVER_INSTALL_DIR/$SERVER_NAME
chown -R jboss:jboss $SERVER_INSTALL_DIR/$REPO_NAME
chown -R jboss:jboss $SERVER_INSTALL_DIR/$MAVEN_DIR

# Configure the server
echo "Configure the Server"
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.sh --admin-only -c $JBOSS_CONFIG &"
sleep 15
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_BPMS"
if [ "$QUARTZ" = "true" ]
then
  su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 --file=$CLI_BPMS_QUARTZ"   
fi
su jboss -c "$SERVER_INSTALL_DIR/$SERVER_NAME/bin/jboss-cli.sh -c --controller=$IP_ADDR:9999 \":shutdown\" "
sleep 10

# Modify persistence.xml
echo "Modify persistence.xml"
sed -i s/java:jboss\\/datasources\\/ExampleDS/java:jboss\\/datasources\\/jbpmDS/ $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml
sed -i s/org.hibernate.dialect.H2Dialect/org.hibernate.dialect.MySQL5Dialect/ $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war/WEB-INF/classes/META-INF/persistence.xml

# Configure dashboard
if [ "$DASHBOARD" == "true" ];
then
  echo "Configure Dashboard app"
  sed -i s/java:jboss\\/datasources\\/ExampleDS/java:jboss\\/datasources\\/jbpmDS/ $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war/WEB-INF/jboss-web.xml
fi

exit 0
