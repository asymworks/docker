#!/bin/bash
#

set -euo pipefail

function echoerr {
    cat <<< "$@" 1>&2;
}

function quit {
    if [ -n "${1:-}" ]; then
        exit "$1"
    fi

    exit 0
}

if [ -z "${RCLONE_REMOTE}" ]; then
	# Do not run rclone
	exit 0
fi

if [ -z "${BORG_REPO:-}" ]; then
    echoerr 'Variable $BORG_REPO is required. Please set it to the repository location.'
    quit 1
fi

if [ -z "${RCLONE_CONFIG}" ]; then
	RC_CONFIG=''
else
	RC_CONFIG="--config ${RCLONE_CONFIG}"
fi

# Run Rclone
rclone -v sync \
	$BORG_REPO \
	$RCLONE_REMOTE \
	--transfers ${RCLONE_TRANSFERS:-32} \
