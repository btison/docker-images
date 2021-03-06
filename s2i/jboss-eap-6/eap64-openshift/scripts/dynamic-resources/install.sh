#!/bin/sh

# Add jboss user to root group
usermod -g root -G jboss jboss

mkdir -p /usr/local/dynamic-resources
cp -p /tmp/scripts/dynamic-resources/dynamic_resources.sh /usr/local/dynamic-resources/

chown -R jboss:root /usr/local/dynamic-resources/
chmod -R g+rwX $dir /usr/local/dynamic-resources/
