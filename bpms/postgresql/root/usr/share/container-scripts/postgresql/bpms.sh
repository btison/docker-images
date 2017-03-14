function execute_scripts() {
  local database=${1?missing argument}
  psql -c "grant all privileges on database ${database} to ${POSTGRESQL_USER};"
  psql -d ${database} < ${CONTAINER_SCRIPTS_PATH}/sql/postgresql-jbpm-schema.sql
  psql -d ${database} < ${CONTAINER_SCRIPTS_PATH}/sql/postgres-dashbuilder-schema.sql
  psql -d ${database} < ${CONTAINER_SCRIPTS_PATH}/sql/quartz_tables_postgres.sql
}
