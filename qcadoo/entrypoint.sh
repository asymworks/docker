#!/bin/bash
#
# Qcadoo Docker Entrypoint
# Copyright (c) 2021 Asymworks, LLC

export PGDB_HOST=${QCADOO_DB_HOST:-db}
export PGDB_PORT=${QCADOO_DB_PORT:-5432}
export PGDB_NAME=${QCADOO_DB_NAME:-mes}
export PGDB_USERNAME=${QCADOO_DB_USERNAME:-qcadoo}
export PGDB_PASSWORD=${QCADOO_DB_PASSWORD:-qcadoo}

abort() {
    local msg=$1
    shift
    local code=${1:-1}
    echo -e "\033[31m\033[1m[ABORT]\033[0m ${msg}"
    exit ${code}
}

info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

pg_wait() {
    # Wait for the PostgreSQL connection to be available
    pg_isready -q -h ${PGDB_HOST} -p ${PGDB_PORT} && return
    info "Waiting for PostgreSQL connection"
    for run in {1..10} ; do
        sleep 3
        pg_isready -q -h ${PGDB_HOST} -p ${PGDB_PORT} && break
    done
    [ $? -eq 0 ] || abort "Timed out waiting for PostgreSQL connection"
}

if [ "$1" == "start" ] ; then
    # Write environment variables into Qcadoo Configuration
    [ -f db.properties.conf ] || abort "Missing db.properties.conf file"
    info "Updating database connection information in db.properties"
    envsubst < db.properties.conf > $HOME/mes-application/qcadoo/db.properties

    # Start the Qcadoo Server
    pg_wait
    info "Starting Qcadoo"
    exec $HOME/mes-application/bin/startup.sh
fi

if [ "$1" == "create-schema" ]; then
    pg_wait
    info "Loading SQL Schema"
    SQL_FILE="${HOME}/mes-application/webapps/ROOT/WEB-INF/classes/schema/demo_db_en.sql"
    PSQL="psql -h ${PGDB_HOST} -p ${PGDB_PORT} -U ${PGDB_USERNAME} ${PGDB_NAME}"
    PGPASSWORD="${PGDB_PASSWORD}" exec $PSQL < $SQL_FILE
fi

exec "$@"
