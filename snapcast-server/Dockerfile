FROM alpine:3.12 as snapweb-builder
ARG SNAPWEB_VERSION=0.1.0

RUN apk add --no-cache make nodejs npm \
 && npm i -g typescript \
 && mkdir /src

WORKDIR /src
RUN wget https://github.com/badaix/snapweb/archive/v${SNAPWEB_VERSION}.tar.gz \
 && tar xzf v${SNAPWEB_VERSION}.tar.gz \
 && cd snapweb-${SNAPWEB_VERSION} \
 && make \
 && mv dist ..

FROM alpine:3.12

RUN apk add --no-cache snapcast \
 && mkdir /tmp/snapcast \
 && chown snapcast:audio /tmp/snapcast

COPY snapserver.conf /etc/snapserver.conf
COPY --from=snapweb-builder /src/dist /snapweb

USER snapcast
EXPOSE 1704 1705 1780
ENTRYPOINT [ "/usr/bin/snapserver" ]
