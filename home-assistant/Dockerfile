ARG BUILD_FROM
FROM ${BUILD_FROM}:4.1

VOLUME /config
WORKDIR /usr/src

## Setup Home Assistant
COPY homeassistant homeassistant

# Add hass user so Home Assistant does not run as root
RUN mkdir /config
RUN addgroup -g 8123 -S hass
RUN adduser -u 8123 -G hass -S -h /usr/src/homeassistant -H hass \
		&& adduser hass dialout \
		&& chown -R hass:hass /config \
		&& chown -R hass:hass /usr/src/homeassistant

# Patch Kodi to Always Poll
COPY 50-always-poll-kodi.patch /tmp/50-always-poll-kodi.patch
RUN patch -p1 < /tmp/50-always-poll-kodi.patch
RUN rm /tmp/50-always-poll-kodi.patch

# Install Dependencies
RUN pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -r homeassistant/requirements_all.txt -c homeassistant/homeassistant/package_constraints.txt \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links "${WHEELS_LINKS}" \
        -e ./homeassistant \
    && python3 -m compileall homeassistant/homeassistant

# Switch to Home Assistant user
USER hass

# Run Home Assistant
WORKDIR /config
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]