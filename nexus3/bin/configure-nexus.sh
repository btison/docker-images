#!/bin/bash

IPADDR=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
CONTINUE=true

while [ "$CONTINUE" = "true" ]; do
  response=$(curl -X GET -u admin:admin123 --write-out %{http_code} --silent --output /dev/null http://$IPADDR:8080/service/siesta/rest/v1/script)
  if [ "$response" = "200" ]; then
    curl -X POST -H "Content-Type: application/json" -u admin:admin123 -d @$CONTAINER_SCRIPTS_PATH/docker-repo.json http://$IPADDR:8080/service/siesta/rest/v1/script
    curl -X POST -H "Content-type: text/plain" -u admin:admin123 http://$IPADDR:8080/service/siesta/rest/v1/script/docker-repo/run
    echo ""
    echo "nexus configured"
    CONTINUE=false
  fi
  sleep 1
done
