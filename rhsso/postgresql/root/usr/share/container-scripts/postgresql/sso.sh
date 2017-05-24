function execute_scripts() {
  local database=${1?missing argument}
  psql -c "grant all privileges on database ${database} to ${POSTGRESQL_USER};"
}