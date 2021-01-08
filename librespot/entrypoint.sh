#!/bin/sh
#

if [ "$1" = "start" ] ; then
    # Run librespot from environment
    /usr/bin/librespot \
        --name "${LIBRESPOT_NAME}" \
        --device-type ${LIBRESPOT_DEVICE_TYPE} \
        ${LIBRESPOT_AUDIO_OPTS} \
        ${LIBRESPOT_EXTRA_OPTS}
fi

exec "$@"
