RESOURCES_DIR=/resources
CONFIGURATION_DIR=/configuration
TOMCAT=$RESOURCES_DIR/apache-tomcat-8.0.11.zip
MYSQL_DRIVER_JAR=mysql-connector-java.jar
MYSQL_DRIVER_JAR_DIR=/usr/share/java
SERVER_INSTALL_DIR=/opt/jboss
SERVER_NAME=apache-tomcat
SERVER_NAME_ORIG=apache-tomcat-8.0.11
MAVEN_SETTINGS_XML=$CONFIGURATION_DIR/maven/settings.xml
MAVEN_DIR=m2
MAVEN_REPO_DIR=$SERVER_INSTALL_DIR/$MAVEN_DIR/repository

#Defaults
NEXUS=true

#NEXUS
NEXUS_URL=nexus:8080
