#!/bin/bash

. env.sh

#Sanity checks
if [ -f /$FSW ];
then
    echo "File $FSW found"
else
    echo "File $FSW does not exists. Please put it in the resources folder"
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
java -jar $FSW /$TEMP_DIR/$(basename $FSW_INSTALL_MANIFEST) -variablefile $FSW_INSTALL_VARIABLES 

#Check successful install
SUCCESS=$(cat $SERVER_INSTALL_DIR/InstallationLog.txt | grep 'Automated installation done')
if [ -z "$SUCCESS" ];
then
    echo "Installation of FSW failed. Check the installation log for details"
    exit 250
fi

echo "Renaming the EAP dir to $SERVER_NAME"
mv $SERVER_INSTALL_DIR/jboss-eap-6.1 $SERVER_INSTALL_DIR/$SERVER_NAME

#echo "Binding JBoss EAP to ${IP_ADDR}"
#RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "jboss.bind.address=" | grep -v "#"`
#if [[ "$RET" == "" ]]
#then
#  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
#  echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${IP_ADDR} -Djboss.bind.address.management=${IP_ADDR} -Djboss.bind.address.unsecure=${IP_ADDR} \"" >> #$SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
#fi

echo "Setting JBoss node name to ${SERVER_NODE_NAME}"
RET=`cat $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf | grep "jboss.node.name=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
  echo $'\n' >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
  echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.node.name=${SERVER_NODE_NAME}\"" >> $SERVER_INSTALL_DIR/$SERVER_NAME/bin/standalone.conf
fi

echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

exit 0
