#! /bin/bash

set -e

SCRIPT_DIR=$(dirname $0)

YELLOW='\033[1;33m'
NC='\033[0m'

# Nexus

pushd $SCRIPT_DIR/../nexus
if ! docker ps | grep -q 'nexus_nexus_1'; then
  docker-compose -p nexus up -d
else
  echo -e "${YELLOW}Nexus container already started. Skipping...${NC}"
fi
popd

# Gogs
pushd $SCRIPT_DIR/../gogs
if ! docker ps | grep -q 'gogs_gogs_1'; then
  docker-compose -p gogs up -d
else
  echo -e "${YELLOW}Gogs container already started. Skipping...${NC}"
fi
popd

# Jenkins
pushd $SCRIPT_DIR/../jenkins/jenkins
if ! docker ps | grep -q 'jenkins_jenkins_1'; then
  docker-compose -p jenkins up -d
else
  echo -e "${YELLOW}Jenkins master container already started. Skipping...${NC}"
fi
popd

pushd $SCRIPT_DIR/../jenkins/jenkins-slave
if ! docker ps | grep -q 'jenkins_jenkins-slave-maven_1'; then
  docker-compose -p jenkins up -d
else
  echo -e "${YELLOW}Jenkins slave container already started. Skipping...${NC}"
fi
popd