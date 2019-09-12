ARG BUILD_FROM
FROM ${BUILD_FROM}:4.1

WORKDIR /usr/src

## Setup Home Assistant
COPY homeassistant homeassistant
RUN pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -e ./homeassistant \
    && python3 -m compileall homeassistant/homeassistant

# Patch Kodi to Always Poll
COPY 50-always-poll-kodi.patch /tmp/50-always-poll-kodi.patch
RUN patch -p1 < /tmp/50-always-poll-kodi.patch
RUN rm /tmp/50-always-poll-kodi.patch

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]