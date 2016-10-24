#!/bin/bash

. /env.sh

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "Tomcat not installed."
  exit 0
fi

# shutdown eap
su jboss <<EOF
${SERVER_INSTALL_DIR}/${SERVER_NAME}/bin/catalina.sh $JPDA stop
EOF

