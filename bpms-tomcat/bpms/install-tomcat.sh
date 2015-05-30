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
##echo "DASHBOARD=$DASHBOARD"
##echo "QUARTZ=$QUARTZ"

# Sanity Checks
if [ -f $TOMCAT ];
then
    echo "File $TOMCAT found"
else
    echo "File $TOMCAT not found. Please put it in the resources folder"
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
echo "Unzipping Tomcat"
unzip -q $TOMCAT -d $SERVER_INSTALL_DIR

echo "Renaming the Tomcat installation dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/$SERVER_NAME_ORIG $SERVER_INSTALL_DIR/$SERVER_NAME

echo "Set system variables for maven repos"
touch $SERVER_INSTALL_DIR/$SERVER_NAME/bin/setenv.sh
chmod 755 $SERVER_INSTALL_DIR/$SERVER_NAME/bin/setenv.sh
echo "CATALINA_OPTS=\"\$CATALINA_OPTS -Dkie.maven.settings.custom=$SERVER_INSTALL_DIR/$MAVEN_DIR/settings.xml\"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/setenv.sh

# Setup maven repo
mkdir -p $SERVER_INSTALL_DIR/$MAVEN_DIR/repository
if [ "$NEXUS" == "true" ]
then
  echo "Setup local maven repo with Nexus"
  cp $MAVEN_SETTINGS_XML $SERVER_INSTALL_DIR/$MAVEN_DIR/$(basename $MAVEN_SETTINGS_XML)
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

# MySQL JDBC driver
echo "Install mysql driver"
cp $MYSQL_DRIVER_JAR_DIR/$MYSQL_DRIVER_JAR $SERVER_INSTALL_DIR/$SERVER_NAME/lib

# Remote debugging
echo "set remote debugging settings"
echo "JPDA_ADDRESS=8787" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/setenv.sh

echo "Change owner to user jboss"
chown jboss:jboss $SERVER_INSTALL_DIR
chown -R jboss:jboss $SERVER_INSTALL_DIR/$SERVER_NAME
chown -R jboss:jboss $SERVER_INSTALL_DIR/$MAVEN_DIR

echo "Change permissions on script files in $SERVER_INSTALL_DIR/$SERVER_NAME/bin"
chmod 755 $SERVER_INSTALL_DIR/$SERVER_NAME/bin/*.sh

exit 0
