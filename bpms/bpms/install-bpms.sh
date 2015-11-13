#!/bin/bash

. env.sh

FORCE=false

while [ "$#" -gt 0 ]
do
    case "$1" in
      --business-central)
          BUSINESS_CENTRAL=true
          ;;
      --no-business-central)
          BUSINESS_CENTRAL=false
          ;;
      --kie-server)
          KIE_SERVER=true
          ;;
      --no-kie-server)
          KIE_SERVER=false
          ;;
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

echo "BUSINESS_CENTRAL=$BUSINESS_CENTRAL"
echo "KIE_SERVER=$KIE_SERVER"
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

# Install bpms
echo "Unzipping EAP"
unzip -q $EAP -d $SERVER_INSTALL_DIR

echo "Unzipping BPMS"
unzip -q -o $BPMS -d $SERVER_INSTALL_DIR

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG $SERVER_INSTALL_DIR/$SERVER_NAME

if [ ! "$DASHBOARD" == "true" ];
then
  echo "Removing dashboard app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/dashbuilder.war.dodeploy
fi

if [ ! "$BUSINESS_CENTRAL" == "true" ];
then
  echo "Removing business-central app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/business-central.war.dodeploy
fi

if [ ! "$KIE_SERVER" == "true" ];
then
  echo "Removing kie_server app"
  rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war
  rm -f $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/kie-server.war.dodeploy
fi

echo "Remove org.kie.example"
sed -i 's/property name="org.kie.example" value="true"/property name="org.kie.example" value="false"/' $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/standalone.xml

echo "Set system variables for maven and git repos"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "org.guvnor.m2repo.dir=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.guvnor.m2repo.dir=$MAVEN_REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.uberfire.nio.git.dir=$BPMS_DATA_DIR/$REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dorg.uberfire.metadata.index.dir=$BPMS_DATA_DIR/$REPO_DIR \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi 

echo "Set system variable for local Maven repo"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "kie.maven.settings.custom=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Dkie.maven.settings.custom=$BPMS_DATA_DIR/configuration/$(basename $MAVEN_SETTINGS_XML) \"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi 

# Setup maven repo
if [ "$NEXUS" == "true" ]
then
  echo "Setup local maven repo with Nexus"
  cp $MAVEN_SETTINGS_XML $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/$(basename $MAVEN_SETTINGS_XML)
  VARS=( MAVEN_REPO_DIR )
  for i in "${VARS[@]}"
  do
    sed -i "s'@@${i}@@'${!i}'" $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/$(basename $MAVEN_SETTINGS_XML)	
  done      
else
  echo "Setup local maven repo off-line"
  touch $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/$(basename $MAVEN_SETTINGS_XML)
  echo "<settings><localRepository>$MAVEN_REPO_DIR</localRepository><offline>true</offline></settings>" >> $SERVER_INSTALL_DIR/$MAVEN_DIR/settings.xml
fi

echo "Create application users admin1:admin & user:user"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "admin1=8b68b1984bd2f4faf6b7a3c6a0c78968" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "busadmin=a8d820ddeedbba0de0a776fd99863419" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
  echo "user1=e6e3515c498a9dd0d3f9ff109a563d70" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-users.properties
fi

RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties | grep "admin1=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "admin1=admin,analyst,user,reviewer,kie-server,kiemgmt" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "busadmin=Administrators,analyst,user,reviewer" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
  echo "user1=user,reviewer" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/application-roles.properties
fi

echo "Create management user admin:admin"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties | grep "admin=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
  echo "admin=c22052286cd5d72239a90fe193737253" >> $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/mgmt-users.properties
fi

# Create directories and set permissions
echo "Make directories for maven and git repo"
mkdir -p $SERVER_INSTALL_DIR/${REPO_DIR}

# Quartz Properties
echo "Copy quartz properties file"
cp $QUARTZ_PROPERTIES $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration

echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

# Configure the server
echo "Configure the Server"
# replace placeholders in cli file
VARS=( MYSQL_MODULE_NAME MYSQL_DRIVER_JAR MYSQL_DRIVER_JAR_DIR )
for i in "${VARS[@]}"
do
    sed -i "s'@@${i}@@'${!i}'" $CLI_BPMS	
done
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
