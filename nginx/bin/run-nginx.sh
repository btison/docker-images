#!/bin/bash

source /opt/app-root/etc/generate_container_user

set -e

exec nginx -g "daemon off;"