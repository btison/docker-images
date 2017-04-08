# Configuration settings.
export POSTGRESQL_MAX_CONNECTIONS=${POSTGRESQL_MAX_CONNECTIONS:-100}
export POSTGRESQL_MAX_PREPARED_TRANSACTIONS=${POSTGRESQL_MAX_PREPARED_TRANSACTIONS:-0}
export POSTGRESQL_SHARED_BUFFERS=${POSTGRESQL_SHARED_BUFFERS:-32MB}

export POSTGRESQL_CONFIG_FILE=$HOME/custom-postgresql.conf

function generate_postgresql_config() {
  envsubst \
      < "${CONTAINER_SCRIPTS_PATH}/custom-postgresql.conf.template" \
      > "${POSTGRESQL_CONFIG_FILE}"
}

function initialize_database() {
  # Initialize the database cluster with utf8 support enabled by default.
  # This might affect performance, see:
  # http://www.postgresql.org/docs/9.2/static/locale.html
  LANG=${LANG:-en_US.utf8} initdb

  # PostgreSQL configuration.
  cat >> "$PGDATA/postgresql.conf" <<EOF

# Custom OpenShift configuration:
include '${POSTGRESQL_CONFIG_FILE}'
EOF

  # Access control configuration.
  # FIXME: would be nice-to-have if we could allow connections only from
  #        specific hosts / subnet
  cat >> "$PGDATA/pg_hba.conf" <<EOF

#
# Custom OpenShift configuration starting at this point.
#

# Allow connections from all hosts.
host all all all md5

# Allow replication connections from all hosts.
# host replication all all md5
EOF

}

function create_users() {
  createuser "$DB_USER" --createdb
}

function create_database() {
  if [[ -n ${DB_NAME} ]]; then
    for database in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_NAME}"); do
      echo "Creating database: ${database}..."
      createdb --owner="$DB_USER" "$database"
      load_extensions ${database}
    done
  fi
}

function load_extensions() {
  local database=${1?missing argument} 

  if [[ -n ${DB_EXTENSION} ]]; then
    for extension in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_EXTENSION}"); do
      echo "Loading ${extension} extension..."
      psql -d ${database} -c "CREATE EXTENSION IF NOT EXISTS ${extension};" #>/dev/null 2>&1
    done
  fi 
}

function set_passwords() {
  psql --command "ALTER USER \"${DB_USER}\" WITH ENCRYPTED PASSWORD '${DB_PASS}';"
}

# Make sure env variables don't propagate to PostgreSQL process.
function unset_env_vars() {
  unset DB_{USER,PASS,NAME}
}

function set_pgdata ()
{
  # create a subdirectory that the user owns
  mkdir -p "${HOME}/data/userdata"
  export PGDATA=$HOME/data/userdata
  # ensure sane perms for postgresql startup
  chmod 700 "$PGDATA"
}