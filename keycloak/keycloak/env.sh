IP_ADDR=127.0.0.1
RESOURCES_DIR=/resources
CONFIGURATION_DIR=/configuration
KEYCLOAK_DISTRO=keycloak-server-dist-1.9.7.Final-redhat-1.zip
KEYCLOAK=$RESOURCES_DIR/$KEYCLOAK_DISTRO
SERVER_INSTALL_DIR=/opt/jboss
SERVER_NAME=rhsso
SERVER_NAME_ORIG=rh-sso-7.0
MYSQL_DRIVER_JAR=mysql-connector-java.jar
MYSQL_DRIVER_JAR_DIR=/usr/share/java
MYSQL_MODULE_NAME=com.mysql
CLI_RHSSO=$CONFIGURATION_DIR/rhsso/rhsso.cli
JBOSS_CONFIG=standalone.xml
JAVA_HOME=/usr/lib/jvm/java
RHSSO_DATA_DIR=$SERVER_INSTALL_DIR/data
