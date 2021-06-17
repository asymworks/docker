FROM alpine:3.12 AS builder

ARG LIBRESPOT_RELEASE=0.2.0
RUN apk add git rust cargo alsa-lib-dev \
 && mkdir /src

WORKDIR /src
RUN wget https://github.com/librespot-org/librespot/archive/v${LIBRESPOT_RELEASE}.tar.gz \
 && tar xzf v${LIBRESPOT_RELEASE}.tar.gz \
 && cd librespot-${LIBRESPOT_RELEASE} \
 && cargo build --release --no-default-features --features alsa-backend --verbose \
 && cp -r target/release/librespot /src/

FROM alpine:3.12

RUN apk add alsa-lib libgcc
COPY --from=builder \
 /src/librespot \
 /usr/bin/librespot
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENV LIBRESPOT_NAME=librespot
ENV LIBRESPOT_DEVICE_TYPE=speaker
ENV LIBRESPOT_AUDIO_OPTS=
ENV LIBRESPOT_EXTRA_OPTS=

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
CMD [ "start" ]