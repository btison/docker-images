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
# Switchyard
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/docs/schema/soa/org/apache/camel/schema/spring/camel-spring.xsd
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/com/thoughtworks/xstream/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/core/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/cxf/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/ftp/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/jms/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/jpa/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/mail/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/netty/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/quartz/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/soap/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/spring/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/apache/camel/sql/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/api/extensions/wsdl/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/api/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/bus/camel/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/common/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/bean/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/bpel/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/bpm/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/camel/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/camel/switchyard/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/common/camel/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/common/knowledge/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/common/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/http/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/jca/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/resteasy/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/rules/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/sca/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/component/soap/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/config/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/deploy/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/remote/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/runtime/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/security/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/transform/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/switchyard/validate/main/
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/switchyard-bpel-console-server.war/WEB-INF/lib/commons-fileupload-1.2.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/switchyard-bpel-console-server.war/WEB-INF/lib/riftsaw-console-integration-*.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/switchyard-bpel-console-server.war/WEB-INF/lib/riftsaw-console-integration-*.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bean-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpel-service/jms_binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpel-service/loan_approval/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpel-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpel-service/say_hello/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpel-service/simple_correlation/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/bpm-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-ftp-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-jaxb/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-jms-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-jpa-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-mail-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-netty-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-quartz-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-soap-proxy/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/camel-sql-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/cluster/client/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/cluster/credit/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/cluster/dealer/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/cluster/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/multiApp/artifacts/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/multiApp/order-consumer/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/multiApp/order-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/multiApp/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/multiApp/web/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/orders/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-basic/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-basic-propagate/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-cert/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-saml/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-wss-signencrypt/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-security-wss-username/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/policy-transaction/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/transaction-propagation/client/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/transaction-propagation/credit/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/transaction-propagation/dealer/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/demos/transaction-propagation/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/ear-deployment/artifacts/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/ear-deployment/ear-assembly/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/ear-deployment/order-consumer/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/ear-deployment/order-service/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/ear-deployment/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/http-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/jca-inflow-hornetq/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/jca-outbound-hornetq/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/remote-invoker/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/rest-binding/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/rules-camel-cbr/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/rules-interview/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/rules-interview-container/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/rules-interview-dtable/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/soap-addressing/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/soap-attachment/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/soap-binding-rpc/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/soap-mtom/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/transform-jaxb/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/transform-json/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/transform-smooks/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/transform-xslt/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/switchyard/validate-xml/pom.xml
unzip $FSW_PATCH_SWITCHYARD -d $RESOURCES_DIR
mv $RESOURCES_DIR/jboss-eap-6.1 $RESOURCES_DIR/$SERVER_NAME
cp -r $RESOURCES_DIR/$SERVER_NAME $SERVER_INSTALL_DIR
rm -rf $RESOURCES_DIR/$SERVER_NAME


echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

exit 0
