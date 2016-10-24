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

# Setup FSW configuration file
cp $FSW_INSTALL_MANIFEST $TEMP_DIR

VARS=( SERVER_INSTALL_DIR MYSQL_DRIVER MYSQL_SCHEMA )
for i in "${VARS[@]}"
do
    sed -i "s'@@${i}@@'${!i}'" /$TEMP_DIR/$(basename $FSW_INSTALL_MANIFEST)	
done

# Install FSW
echo "Installing FSW"
java -jar $FSW /tmp/$(basename $FSW_INSTALL_MANIFEST) -variablefile $FSW_INSTALL_VARIABLES 

# Check successful install
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

# Apply Rollup Patch 3
echo "Apply Fuse Service Works 6.0.0 Rollup Patch 3"
unzip -q $FSW_PATCH_ZIP -d $RESOURCES_DIR
# Base Installation
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bin/client/jboss-cli-client.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bin/client/jboss-client.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/bundles/system/layers/base/org/jboss/as/osgi/configadmin/main/jboss-as-osgi-configadmin-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/jboss-modules.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/apache/xalan/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/apache/xalan/main/serializer-2.7.1-redhat-3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/apache/xalan/main/xalan-2.7.1-redhat-3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/fusesource/jansi/main/jansi-1.9-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/fusesource/jansi/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/hornetq/main/hornetq-journal-2.3.5.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/hornetq/ra/main/hornetq-ra-2.3.5.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/appclient/main/jboss-as-appclient-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/appclient/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/cli/main/jboss-as-cli-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/cli/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/api/main/jboss-as-clustering-api-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/api/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/common/main/jboss-as-clustering-common-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/common/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/ejb3/infinispan/main/jboss-as-clustering-ejb3-infinispan-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/ejb3/infinispan/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/impl/main/jboss-as-clustering-impl-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/impl/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/infinispan/main/jboss-as-clustering-infinispan-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/infinispan/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/jgroups/main/jboss-as-clustering-jgroups-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/jgroups/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/registry/main/jboss-as-clustering-registry-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/registry/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/service/main/jboss-as-clustering-service-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/service/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/singleton/main/jboss-as-clustering-singleton-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/singleton/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/web/infinispan/main/jboss-as-clustering-web-infinispan-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/web/infinispan/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/web/spi/main/jboss-as-clustering-web-spi-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/clustering/web/spi/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/cmp/main/jboss-as-cmp-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/cmp/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/configadmin/main/jboss-as-configadmin-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/configadmin/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/connector/main/jboss-as-connector-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/connector/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/controller/main/jboss-as-controller-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/controller/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/controller-client/main/jboss-as-controller-client-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/controller-client/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/deployment-repository/main/jboss-as-deployment-repository-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/deployment-repository/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/deployment-scanner/main/jboss-as-deployment-scanner-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/deployment-scanner/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/domain-http-interface/main/jboss-as-domain-http-interface-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/domain-http-interface/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/domain-management/main/jboss-as-domain-management-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/domain-management/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ee/deployment/main/jboss-as-ee-deployment-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ee/deployment/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ee/main/jboss-as-ee-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ee/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ejb3/main/jboss-as-ejb3-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/ejb3/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/embedded/main/jboss-as-embedded-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/embedded/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/host-controller/main/jboss-as-host-controller-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/host-controller/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jacorb/main/jboss-as-jacorb-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jacorb/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jaxr/main/jboss-as-jaxr-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jaxr/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jaxrs/main/jboss-as-jaxrs-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jaxrs/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jdr/main/jboss-as-jdr-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jdr/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jdr/main/resources/plugins.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jmx/main/jboss-as-jmx-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jmx/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/hibernate/3/jboss-as-jpa-hibernate3-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/hibernate/3/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/hibernate/4/jboss-as-jpa-hibernate4-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/hibernate/4/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/main/jboss-as-jpa-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/spi/main/jboss-as-jpa-spi-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/spi/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/util/main/jboss-as-jpa-util-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jpa/util/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf/main/jboss-as-jsf-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf-injection/1.2/jboss-as-jsf-injection-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf-injection/1.2/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf-injection/main/jboss-as-jsf-injection-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsf-injection/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsr77/main/jboss-as-jsr77-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/jsr77/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/logging/main/jboss-as-logging-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/logging/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/mail/main/jboss-as-mail-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/mail/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/management-client-content/main/jboss-as-management-client-content-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/management-client-content/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/messaging/main/jboss-as-messaging-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/messaging/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/jboss-as-modcluster-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/mod_cluster-container-catalina-1.2.4.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/mod_cluster-container-jbossweb-1.2.4.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/mod_cluster-container-spi-1.2.4.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/mod_cluster-core-1.2.4.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/modcluster/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/naming/main/jboss-as-naming-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/naming/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/network/main/jboss-as-network-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/network/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/http/main/jboss-as-osgi-http-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/http/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jmx/main/jboss-as-osgi-jmx-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jmx/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jpa/main/jboss-as-osgi-jpa-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jpa/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jta/main/jboss-as-osgi-jta-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/jta/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/main/jboss-as-osgi-service-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/naming/main/jboss-as-osgi-naming-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/naming/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/web/main/jboss-as-osgi-web-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/osgi/web/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/platform-mbean/main/jboss-as-platform-mbean-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/platform-mbean/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/pojo/main/jboss-as-pojo-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/pojo/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/process-controller/main/jboss-as-process-controller-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/process-controller/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/product/eap/dir/META-INF/MANIFEST.MF
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/protocol/main/jboss-as-protocol-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/protocol/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/remoting/main/jboss-as-remoting-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/remoting/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/sar/main/jboss-as-sar-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/sar/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/security/main/jboss-as-security-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/security/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/server/main/jboss-as-server-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/server/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/standalone/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/system-jmx/main/jboss-as-system-jmx-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/system-jmx/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/threads/main/jboss-as-threads-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/threads/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/transactions/main/jboss-as-transactions-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/transactions/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/version/main/jboss-as-version-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/version/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/web/main/ecj-3.7.2-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/web/main/jboss-as-web-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/web/main/jbossweb-7.2.2.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/web/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/webservices/main/jboss-as-webservices-server-integration-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/webservices/main/jbossws-cxf-resources-4.1.4.Final-redhat-7-jboss711.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/webservices/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/weld/main/jboss-as-weld-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/weld/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/xts/main/jboss-as-xts-7.2.1.Final-redhat-10.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/as/xts/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/vfs/main/jboss-vfs-3.1.0.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/jboss/vfs/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/kohsuke/rngom/main/rngom-201103-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/opensaml/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/opensaml/main/opensaml-2.5.1.redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/opensaml/main/openws-1.4.2.redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/opensaml/main/xmltooling-1.3.2-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/picketbox/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/picketbox/main/picketbox-4.0.17.SP2-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/picketbox/main/picketbox-commons-1.0.0.final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/base/org/picketbox/main/picketbox-infinispan-4.0.17.SP2-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/version.txt
unzip -q $FSW_PATCH_BASE -d $RESOURCES_DIR
mv $RESOURCES_DIR/jboss-eap-6.1 $RESOURCES_DIR/$SERVER_NAME
cp -r $RESOURCES_DIR/$SERVER_NAME $SERVER_INSTALL_DIR
rm -rf $RESOURCES_DIR/$SERVER_NAME 
# RTGOV
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/drools-compiler-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/drools-core-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/drools-decisiontables-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/drools-persistence-jpa-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/drools-templates-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/drools/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/eclipse/jdt/core/compiler/main/ecj-3.7.2-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/eclipse/jdt/core/compiler/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-audit-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-bpmn2-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-flow-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-flow-builder-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-human-task-core-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-human-task-workitems-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-kie-services-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-meta-inf-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-persistence-jpa-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-runtime-manager-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-shared-services-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/jbpm-workitems-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/jbpm/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/kie/main/kie-api-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/kie/main/kie-internal-6.0.0-redhat-9.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/kie/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/mvel/mvel2/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/mvel/mvel2/main/mvel2-2.1.7.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/commons/overlord-commons-auth/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/commons/overlord-commons-auth/main/overlord-commons-auth-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/acs-epn-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/active-collection-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/activity-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/analytics-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/ep-core-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/ep-drools-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/ep-mvel-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/epn-core-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/module.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/modules/system/layers/soa/org/overlord/rtgov/main/rtgov-common-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/src/main/java/org/overlord/rtgov/samples/jbossas/activityclient/ActivityClient.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/src/main/resources/txns/OrderButter.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/src/main/resources/txns/OrderJam.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/activityclient/src/main/resources/txns/Transactions.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/DeliveryAck.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/InventoryService.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/InventoryServiceBean.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/Item.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/ItemNotFoundException.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/LogisticsService.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/LogisticsServiceBean.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/Order.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/OrderAck.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/OrderService.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/OrderServiceBean.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/Payment.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/Receipt.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/Transformers.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/interceptors/ExchangeValidator.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/java/org/overlord/rtgov/quickstarts/demos/orders/interceptors/PolicyEnforcer.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/main/resources/wsdl/OrderService.wsdl
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/java/org/overlord/rtgov/quickstarts/demos/orders/OrdersClient.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/resources/xml/fredpay.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/resources/xml/order1.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/resources/xml/order2.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/resources/xml/order3.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/app/src/test/resources/xml/order4.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/ip/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/ip/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/ip/src/main/resources/ip.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/ordermgmt/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/src/main/resources/AssessCredit.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/src/main/resources/epn.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/src/test/java/org/overlord/rtgov/samples/policy/async/EPNTest.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/async/src/test/resources/rtgov-infinispan.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/src/main/resources/VerifyLastUsage.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/src/main/resources/av.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/src/test/java/org/overlord/rtgov/samples/policy/sync/AISTest.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/policy/sync/src/test/resources/rtgov-infinispan.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/epn/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/epn/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/epn/src/main/resources/SLAViolation.drl
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/epn/src/main/resources/epn.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/src/main/java/org/overlord/rtgov/samples/jbossas/slamonitor/monitor/SLAMonitor.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/src/main/java/org/overlord/rtgov/samples/jbossas/slamonitor/monitor/SLAMonitorApplication.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/monitor/src/main/webapp/WEB-INF/web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/Readme.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/pom.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/src/main/resources/SLAReport.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/src/main/resources/reports.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/quickstarts/overlord/rtgov/sla/report/src/test/java/org/overlord/rtgov/reports/sla/SLAReportTest.java
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/gadget-server.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/overlord-apps/gadget-server-overlordapp.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/configuration/overlord-rtgov.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/WEB-INF/jboss-web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/WEB-INF/picketlink.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/WEB-INF/web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/hosted/index.jsp
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/index.jsp
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/idp-responsive.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/idp.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/login-background-phone.jpg
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/login-background-phone_rh.jpg
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/login-background.jpg
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/login-background_rh.jpg
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/login-screen-logo_rh.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war/resources/images/logo-type_rh.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-commons-idp.war.dodeploy
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/clear.cache.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/corner.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/corner_ie6.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/hborder.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/hborder_ie6.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/corner_dialog_topleft.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/corner_dialog_topright.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/hborder_blue_shadow.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/hborder_gray_shadow.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/vborder_blue_shadow.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/ie6/vborder_gray_shadow.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/splitPanelThumb.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/vborder.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/images/vborder_ie6.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/standard.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt/standard/standard_rtl.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application/gwt-log-triangle-10x10.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/Application.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/authorize.jsp
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/config/oauth.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/config/oauth2.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/gwt-proxy.properties
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/log4j.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/apache/shindig/sample/container/SampleContainerGuiceModule.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/apache/shindig/sample/container/SampleContainerHandler.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/apache/shindig/sample/shiro/SampleShiroRealm.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/apache/shindig/sample/shiro/ShiroGuiceModule.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationEntryPoint$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationEntryPoint$2.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationEntryPoint.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationModule.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationPlaceManager.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationProperties.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/ApplicationUI.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/BootstrapContext.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/NameTokens.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/URLBuilder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/auth/CurrentUser.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/model/JSOModel.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/model/JSOParser.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/IndexPresenter$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/IndexPresenter$IndexProxy.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/IndexPresenter$IndexView.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/IndexPresenter.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/StorePresenter$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/StorePresenter$StoreProxy.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/StorePresenter$StoreView.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/presenter/StorePresenter.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/util/RestfulInvoker$Response.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/util/RestfulInvoker.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/util/UUID.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/Footer$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/Footer.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/IndexViewImpl$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/IndexViewImpl$2.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/IndexViewImpl.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/StoreViewImpl$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/view/StoreViewImpl.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/AddTabForm$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/AddTabForm$DialogUiBinder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/AddTabForm.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/ListItem.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/MessageWindow$WindowUiBinder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/MessageWindow.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/PortalLayout.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$2$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$2.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$3.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$4.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$5.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$6.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$7$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$7.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$8.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet$PortletUiBinder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/Portlet.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/ProgressBar.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/StoreItem$1$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/StoreItem$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/StoreItem$StoreItemUiBinder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/StoreItem.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/TabLayout$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/TabLayout$2.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/TabLayout$TabLayoutUiBinder.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/TabLayout.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/client/widgets/UnorderedList.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/EncryptedBlobSecurityTokenService.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/GadgetMetadataService.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/GadgetServerModule.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/GsonFactory.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/RestApplication.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/SQLDateTypeAdapter.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/SecurityTokenService.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/ShindigGadgetMetadataService.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/StoreController.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/UserController.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/filters/JSONPFilter$1.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/filters/JSONPFilter.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/AuthenticatingHttpFetcher.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/AuthenticationConstants.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/AuthenticationModule.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/AuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/AuthorizationHeaderAuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/BasicAuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/HttpHeaderAuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/NoAuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/http/auth/SAMLBearerTokenAuthenticationProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/listeners/ShindigResteasyBootstrapServletContextListener.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/servlets/RestProxyAuthProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/servlets/RestProxyBasicAuthProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/servlets/RestProxySAMLBearerTokenAuthProvider.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/server/servlets/RestProxyServlet.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/PageModel.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/PageResponse.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/Pair.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/StoreItemModel.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/UserModel.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/UserPreference$Option.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/UserPreference$Type.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/UserPreference$UserPreferenceSetting.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/UserPreference.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/org/overlord/gadgets/web/shared/dto/WidgetModel.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/classes/security_token_encryption_key.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/deploy/Application/rpcPolicyManifest/manifest.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/jboss-deployment-structure.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/jboss-web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/activation-1.1.1-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/antlr-2.7.7-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/aopalliance-1.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/args4j-2.0.12-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/caja-r4527.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/closure-compiler-r1741.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-beanutils-1.8.3.redhat-3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-codec-1.4-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-collections-3.2.1-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-configuration-1.6-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-fileupload-1.2.2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-io-2.1-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-lang-2.6-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-lang3-3.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/commons-logging-1.1.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/dom4j-1.6.1-redhat-5.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/ehcache-core-2.5.1-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/el-api-6.0.33.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gadget-core-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/geronimo-stax-api_1.0_spec-1.0.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gin-1.5.0-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gson-1.7.2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/guava-10.0.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/guice-3.0-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/guice-assistedinject-3.0-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/guice-multibindings-3.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gwt-log-3.1.3-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gwt-servlet-2.5.0-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gwtp-build-tools-0.7-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gwtp-clients-common-0.7-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/gwtp-mvp-client-0.7-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/h2-1.3.168-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/hibernate-commons-annotations-4.0.1.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/hibernate-core-4.2.0.SP1-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/hibernate-entitymanager-4.2.0.SP1-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/hibernate-jpa-2.0-api-1.0.1.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/htmlparser-r4209.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/httpclient-4.2.1-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/httpcore-4.2.1-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/icu4j-3.4.5.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jackson-core-asl-1.9.9-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jackson-jaxrs-1.9.9-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jackson-mapper-asl-1.9.9-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jackson-xc-1.9.9-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jarjar-1.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jasper-el-6.0.33.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/javassist-3.15.0-GA-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/javax.inject-1-redhat-3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jboss-annotations-api_1.1_spec-1.0.1.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jboss-jaxrs-api_1.1_spec-1.0.1.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jboss-logging-3.1.2.GA-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jboss-servlet-api_3.0_spec-1.0.2.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jboss-transaction-api_1.1_spec-1.0.1.Final-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jcip-annotations-1.0-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jcl-over-slf4j-1.7.2-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jdom-1.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/joda-time-1.6.2-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/json-20070829.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/json-simple-1.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/jsr305-1.3.9-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/juel-impl-2.2.4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/modules-0.3.2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/nekohtml-1.9.14.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/oauth-20100527.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/oauth-consumer-20090617.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/oauth-httpclient4-20090913.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/oauth-provider-20100527.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/overlord-commons-auth-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/overlord-commons-config-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/overlord-commons-uiheader-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/protobuf-java-2.5.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/resteasy-guice-2.3.6.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/resteasy-jackson-provider-2.3.6.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/resteasy-jaxrs-2.3.6.Final-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/rome-1.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/sanselan-0.97-incubator.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/scannotation-1.0.2-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shindig-common-3.0.0-beta4-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shindig-extras-3.0.0-beta4-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shindig-features-3.0.0-beta4-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shindig-gadgets-3.0.0-beta4-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shindig-social-api-3.0.0-beta4-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shiro-core-1.1.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/shiro-web-1.1.0.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/slf4j-api-1.7.2-redhat-1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xml-apis-1.3.04.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xml-resolver-1.2-redhat-3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xmlpull-1.1.3.1.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xpp3_min-1.1.4c-redhat-2.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/lib/xstream-1.4.3.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/picketlink.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/WEB-INF/web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/Bridge.as
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/Bridge.fla
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/Bridge.swf
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/gadgets.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/rpctest_childgadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/rpctest_gadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/sample-payment.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/sample-pubsub-2-publisher.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/sample-pubsub-2-subscriber.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/sample-pubsub-publisher.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/container/sample-pubsub-subscriber.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/editor/CodeMirror-0.8/css/docs.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/editor/CodeMirror-0.8/css/xmlcolors.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/favicon.ico
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance/javascript-tests/1.1/activities/suite.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance/javascript-tests/1.1/appdata/suite.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance/javascript-tests/1.1/people/suite.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance/javascript-tests/1.1/suite.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/ExpressionLangSample.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/customTagTemplates.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/helloViewerAndFriends.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/helloWorld.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/helloWorld_FriendsAndViews.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/nestedCustomTagsWithFriends.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/osVarTestGadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/ownerRequestViewerRequest.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/gadgets/compliance-1.0/sampleAlbumAndContents.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/bg_blue.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/overlord_logo.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/savara_logo_hori.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_flat_0_aaaaaa_40x100.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_flat_55_fbec88_40x100.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_glass_75_d0e5f5_1x400.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_glass_85_dfeffc_1x400.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_glass_95_fef1ec_1x400.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_gloss-wave_55_5c9ccc_500x100.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_inset-hard_100_f5f8f9_1x100.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-bg_inset-hard_100_fcfdfd_1x100.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_217bc0_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_2e83ff_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_469bdd_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_6da8d5_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_cd0a0a_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_d8e7f3_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/ui-icons_f9bd01_256x240.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/images/user.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/jquery-ui-1.8.18.custom.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/login.jsp
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/logout.jsp
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/ActivityStreams/ActivityStreamGadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/ActivityStreams/ActivityStreamTemplate.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/ContainerPublish.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/DynamicSizeDemo.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/FlashBridgeCajaExample.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/FlashCajaExample.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SharedLockedDomainDemo1.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SharedLockedDomainDemo2.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SharedScriptFrameDemo.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SocialActivitiesWorld.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SocialCajaWorld.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/SocialHelloWorld.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/bubble.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/commoncontainer/gadgetCollections.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/commoncontainer/pubsub2.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/commoncontainer/sample-views.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/commoncontainer/viewsMenu.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/conservcontainer/portlet.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/conservcontainer/sample-actions-runner.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/conservcontainer/sample-actions-voip.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/conservcontainer/sample-selection-listener.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/embeddedexperiences/AlbumViewer.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/embeddedexperiences/PhotoList.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/getFriendsHasApp.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/icon.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/media/Media.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/media/styles.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/media-openGadgets/Media.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/media-openGadgets/styles.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/new.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/nophoto.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth2/oauth2_facebook.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth2/oauth2_google.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth2/oauth2_windowslive.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth2/shindig_authorization.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/oauth2/shindig_client_credentials.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/rewriter/feather.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/rewriter/rewriter1.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/rewriter/rewriter2.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/rewriter/rewriteroff.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/rewriter/rewriteron.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/shindigoauth.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/examples/templates/FlashTag.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/state-basicfriendlist.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/state-smallfriendlist.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/samplecontainer/state.dtd
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/sampledata/canonicaldb.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war/xpc.swf
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadget-web.war.dodeploy
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/WEB-INF/web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/README.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/calltrace.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/gadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/green-circle.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/icons-rtl.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/icons.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/loading.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/red-circle.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/task.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/ui.dynatree.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/vline-rtl.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/vline.gif
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/skin/warning.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/tabs.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/calltrace-gadget/thumbnail.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/rt-gadget/README.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/rt-gadget/d3.css
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/rt-gadget/gadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/rt-gadget/sampledata.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/rt-gadget/thumbnail.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/situation-gadget/README.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/situation-gadget/arrows.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/situation-gadget/gadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/situation-gadget/thumbnail.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/so-gadget/README.txt
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/so-gadget/gadget.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/so-gadget/gen.svg
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war/so-gadget/thumbnail.png
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/gadgets.war.dodeploy
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/AggregateServiceResponseTime.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/MaintainServiceDefinitions.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/SituationDescription.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/SituationType.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/TidyServiceDefinitions.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/classes/acs.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war/WEB-INF/lib/acs-loader-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-acs.war.dodeploy
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war/WEB-INF/classes/epn.json
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war/WEB-INF/classes/org/overlord/rtgov/content/epn/SOAActivityTypeEventSplitter.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war/WEB-INF/classes/org/overlord/rtgov/content/epn/ServiceDefinitionProcessor.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war/WEB-INF/classes/org/overlord/rtgov/content/epn/ServiceResponseTimeProcessor.class
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war/WEB-INF/lib/epn-loader-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov-epn.war.dodeploy
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/beans.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/classes/SeverityAnalyzer.mvel
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/jboss-web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/active-collection-infinispan-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/active-collection-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/active-collection-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-client-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-server-epn-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-server-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-server-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/activity-store-jpa-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/call-trace-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/call-trace-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/collector-activity-server-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/ep-jpa-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/epn-container-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/overlord-commons-auth-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/overlord-commons-config-1.1.0-redhat-7.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/reports-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/reports-jee-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/reports-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/rtgov-client-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/rtgov-infinispan-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/rtgov-jbossas-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/rtgov-switchyard-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/service-dependency-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/service-dependency-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/service-dependency-svg-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/situation-manager-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/lib/situation-manager-rests-1.0.1.Final-redhat-4.jar
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war/WEB-INF/web.xml
rm -rf $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments/overlord-rtgov/overlord-rtgov.war.dodeploy
unzip -q $FSW_PATCH_RTGOV -d $RESOURCES_DIR
mv $RESOURCES_DIR/jboss-eap-6.1 $RESOURCES_DIR/$SERVER_NAME
cp -r $RESOURCES_DIR/$SERVER_NAME $SERVER_INSTALL_DIR
rm -rf $RESOURCES_DIR/$SERVER_NAME

# change owner to user jboss
echo "Change owner to user jboss"
chown -R jboss:jboss $SERVER_INSTALL_DIR

