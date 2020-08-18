#!/bin/bash
#
# Adapted from https://github.com/pschiffe/docker-borg/blob/master/borg-backup.sh

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

if [ -z "${BORG_REPO:-}" ]; then
    echoerr 'Variable $BORG_REPO is required. Please set it to the repository location.'
    quit 1
fi

if [ -z "${BORG_PASSPHRASE:-}" ]; then
	if [ -z "${BORG_NO_ENCRYPTION:-}" ]; then
		echoerr 'Variable $BORG_PASSPHRASE is required. Please set it to the repository passphrase.'
		quit 1
	fi
fi

# Setup SSH Identity
BORG_RSH='ssh'
if [ "${BORG_REPO:0:1}" != '/' ]; then
	if [ -z "${SSH_KEYFILE}" ]; then
		echoerr 'Variable $SSH_KEYFILE is required for remote repositories. Please set it to a public key file.'
		quit 1
	fi
	export BORG_RSH="ssh -o \"StrictHostKeyChecking=no\" -i ${SSH_KEYFILE}"
fi

# Borg needs these
export BORG_REPO
export BORG_PASSPHRASE

# Create Archive Name
ARCHIVE_HOSTNAME="${ARCHIVE_HOSTNAME:-$HOSTNAME}"
DEFAULT_ARCHIVE="${ARCHIVE_HOSTNAME}-$(date +%Y-%m-%d)"
ARCHIVE="${ARCHIVE:-$DEFAULT_ARCHIVE}"

# Load Backup Directories
BACKUP_DIRS="${BACKUP_DIRS:-/mnt/backup}"

if [ -z "${EXCLUDE_FILE:-}" ]; then
	EXCLUDES=''
else
	EXCLUDES="--exclude-from ${EXCLUDE_FILE} "
fi

# Create Archive
borg create -v --stats --show-rc \
	$EXCLUDES \
	::${ARCHIVE} \
	$BACKUP_DIRS

# Prune old Archives
if [ -n "${PRUNE:-}" ]; then
    if [ -n "${PRUNE_PREFIX:-}" ]; then
        PRUNE_PREFIX="--prefix=${PRUNE_PREFIX}"
    else
        PRUNE_PREFIX=''
    fi
    if [ -z "${KEEP_DAILY:-}" ]; then
        KEEP_DAILY=7
    fi
    if [ -z "${KEEP_WEEKLY:-}" ]; then
        KEEP_WEEKLY=4
    fi
    if [ -z "${KEEP_MONTHLY:-}" ]; then
        KEEP_MONTHLY=6
    fi

    borg prune -v --stats --show-rc $PRUNE_PREFIX --keep-daily=$KEEP_DAILY --keep-weekly=$KEEP_WEEKLY --keep-monthly=$KEEP_MONTHLY
fi

# Check the Backup
if [ "${BORG_SKIP_CHECK:-}" != '1' ] && [ "${BORG_SKIP_CHECK:-}" != "true" ]; then
    borg check -v --show-rc
fi

# Done
quit