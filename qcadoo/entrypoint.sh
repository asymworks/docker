#!/bin/bash
#
# Qcadoo Docker Entrypoint
# Copyright (c) 2021 Asymworks, LLC

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-mes}
DB_USERNAME=${DB_USERNAME:-postgres}
DB_PASSWORD=${DB_PASSWORD:-postgres123}

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

check_configuration() {
    # Write environment variables into Qcadoo Configuration
    [ -f db.properties.conf ] || abort "Missing db.properties.conf file"
    info "Updating database connection information in db.properties"
    envsubst < db.properties.conf > $HOME/mes-application/qcadoo/db.properties
}

wait_for_postgres() {
    # Wait for the PostgreSQL connection to be available
    info "Waiting for PostgreSQL connection"
    for run in {1..10} ; do
        pg_isready -h ${DB_HOST} -p ${DB_PORT} -d ${DB_NAME} && break
    done
    [ $? -eq 0 ] || abort "Timed out waiting for PostgreSQL connection"
}

startup() {
    # Start the Qcadoo Server
    info "Starting Qcadoo"
    $HOME/mes-application/bin/startup.sh
}

if [ "$1" == "start" ] ; then
    check_configuration
    wait_for_postgres
    startup
fi

exec $@