#!/bin/bash

set -eu

source "${CONTAINER_SCRIPTS_PATH}/common.sh"

set_pgdata
generate_postgresql_config

if [ ! -f "$PGDATA/postgresql.conf" ]; then
  initialize_database
  NEED_TO_CREATE_USERS=yes
fi

pg_ctl -w start -o "-h ''"
if [ "${NEED_TO_CREATE_USERS:-}" == "yes" ]; then
  create_users
  create_database
fi
set_passwords
pg_ctl stop

unset_env_vars

exec postgres "$@"