#!/bin/bash

. /env.sh

# Sanity checks
if [ ! -d $SERVER_INSTALL_DIR/$SERVER_NAME ]
then
  echo "FSW not installed."
  exit 255
fi

echo "Deploying angrytweet epn app"
chown jboss:jboss $APP_ANGRYTWEET_EPN_SITUATION
su jboss -c "cp $APP_ANGRYTWEET_EPN_SITUATION $SERVER_INSTALL_DIR/$SERVER_NAME/standalone/deployments"
