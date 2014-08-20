IP_ADDR=127.0.0.1
RESOURCES_DIR=/resources
CONFIGURATION_DIR=/configuration
EAP=$RESOURCES_DIR/jboss-eap-6.1.1.zip
BPMS=$RESOURCES_DIR/jboss-bpms-6.0.2.GA-redhat-5-deployable-eap6.x.zip
SERVER_INSTALL_DIR=/opt/jboss
REMOVE_DASHBOARD=true
SERVER_NAME=bpms
REPO_DIR=bpms-repo
MAVEN_DIR=m2
MAVEN_REPO_DIR=$SERVER_INSTALL_DIR/$MAVEN_DIR/repository
NEXUS=false
MAVEN_SETTINGS_XML=$RESOURCES_DIR/maven/settings.xml
MYSQL_DRIVER_JAR=mysql-connector-java-5.1.28.jar
MYSQL_DRIVER_JAR_DIR=$RESOURCES_DIR
MYSQL_MODULE_NAME=com.mysql
MYSQL_MODULE=$CONFIGURATION_DIR/mysql/module.xml
CLI_JBPM_DS=$CONFIGURATION_DIR/jboss-as/jbpmDS-ds.cli
JBOSS_CONFIG=standalone.xml
JAVA_HOME=
